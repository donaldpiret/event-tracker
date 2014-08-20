require 'core_ext/hash'
require 'event_tracker/tracker'
require 'event_tracker/segment_io'

module EventTracker
  class Config
    attr_accessor :segment_io_key
    attr_accessor :disabled
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield self.config
  end

  def self.disabled?
    @config.disabled == true
  end

  # Defines all the helper methods that become available at the controller level
  module HelperMethods
    def track_event(event_name, args = {})
      (session[:tracker_events] ||= []) << [event_name, _sanitize_args(args)]
    end

    def register_properties(args)
      (session[:tracker_properties] ||= {}).merge!(_sanitize_args(args))
    end

    def track_pageview(name, category, args = {})
      (session[:tracker_pageviews] ||= []) << [name, category, _sanitize_args(args)]
    end

    def create_alias(identity1, identity2)
      (session[:tracker_alias] ||= []) << [identity1, identity2]
    end

    def track_transaction(event_name, args = {})
      (session[:tracker_transactions] ||= []) << [event_name, _sanitize_args(args)]
    end

    def identify_for_user(user, with_info = false)
      _trackers.each do |tracker|
        tracker.identify_for_identity(_tracker_identity(user), with_info)
      end
    end

    def create_alias_for_user(identity1, identity2)
      _trackers.each do |tracker|
        tracker.create_alias_for_identity(identity1, identity2)
      end
    end

    def track_event_for_user(user, event_name, args = {})
      _trackers.each do |tracker|
        tracker.track_event_for_identity(_tracker_identity(user), event_name, _sanitize_args(args))
      end
    end

    def track_transaction_for_user(user, event_name, args = {})
      _trackers.each do |tracker|
        tracker.track_transaction_for_identity(_tracker_identity(user), event_name, _sanitize_args(args))
      end
    end
  end

  module ActionControllerExtension
    def append_tracker
      return if EventTracker.disabled? || _trackers.empty?
      body = response.body
      head_insert_at = body.index('</head')
      return unless head_insert_at
      body.insert head_insert_at, view_context.javascript_tag(_trackers.map {|t| t.init }.join("\n"))
      body_insert_at = body.index('</body')
      return unless body_insert_at
      a = [] # Array of all javascript strings to insert

      properties = session.delete(:tracker_properties)
      events = session.delete(:tracker_events)
      pageviews = session.delete(:tracker_pageviews)
      alias_list = session.delete(:tracker_alias)
      transactions = session.delete(:tracker_transactions)

      _trackers.each do |tracker|
        tracker.set_options(request: request)

        a << tracker.identify(_tracker_identity)

        # a << tracker.track_pageview() # No need for this anymore. Done by default
        if pageviews.present?
          pageviews.each do |url, properties|
            a << tracker.track_pageview(url, properties)
          end
        end

        a << tracker.add_properties(properties) if properties.present?

        if events.present?
          events.each do |event_name, properties|
            a << tracker.track_event(event_name, properties)
          end
        end

        if alias_list.present?
          alias_list.each do |identity1, identity2|
            a << tracker.create_alias(identity1, identity2)
          end
        end

        if transactions.present?
          transactions.each do |event_name, properties|
            a << tracker.track_transaction(event_name, properties)
          end
        end
      end

      body.insert body_insert_at, view_context.javascript_tag(a.compact.join("\n"))
      response.body = body
    end

    def _trackers
      return [] if EventTracker.disabled?
      @_trackers ||= begin
        t = []
        t << _segment_io_tracker if _segment_io_tracker
        t
      end
    end

    def _sanitize_args(args)
      args.each do |k, v|
        if v.is_a?(Hash)
          args[k] = _sanitize_args(v)
        elsif v.is_a?(String)
          args[k] = ActionController::Base.helpers.sanitize(v)
        else
          args[k] = v
        end
      end
      return args
    end

    def _tracker_identity(user = nil)
      respond_to?(:analytics_identity, true) ? send(:analytics_identity, user) : nil
    end

    def _segment_io_tracker
      @_segment_io_tracker ||= begin
        key = EventTracker.config.segment_io_key
        key ? EventTracker::SegmentIo.new(key: key) : nil
      end
    end
  end
end