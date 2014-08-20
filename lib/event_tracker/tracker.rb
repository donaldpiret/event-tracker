module EventTracker
  # Abstract class from which every tracker inherits. Shows all supported methods
  class Tracker
    def init

    end

    def set_options(options = {})

    end

    def identify(identity = nil)

    end

    def create_alias(identity1, identity2)

    end

    def add_properties(properties = nil)

    end

    def track_pageview(url = nil, properties = {})

    end

    def track_event(event_name = nil, properties = {})

    end

    def track_transaction(event_name, properties = {})

    end

    def identify_for_identity(identity = nil, with_info = false)

    end

    def create_alias_for_identity(identity1, identity2)

    end

    def track_event_for_identity(identity, event_name = nil, properties = {})

    end

    def track_transaction_for_identity(identity, event_name, properties = {})

    end
  end
end