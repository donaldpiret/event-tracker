module EventTracker
  module ActionControllerExtension
    def self.included(base)
      base.send(:after_filter, :_append_tracker)
    end
    
    def _append_tracker
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