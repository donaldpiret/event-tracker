module EventTracker
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
end