module EventTracker
  class SegmentIo < Tracker
    JS_ESCAPE_MAP = {
        '\\'    => '\\\\',
        '</'    => '<\/',
        "\r\n"  => '\n',
        "\n"    => '\n',
        "\r"    => '\n',
        '"'     => '\\"',
        "'"     => "\\'"
    }


    def initialize(options = {})
      @key = options[:key]
    end

    def init
      <<-EOD
      !function(){var analytics=window.analytics=window.analytics||[];if(!analytics.initialize)if(analytics.invoked)window.console&&console.error&&console.error("Segment snippet included twice.");else{analytics.invoked=!0;analytics.methods=["trackSubmit","trackClick","trackLink","trackForm","pageview","identify","group","track","ready","alias","page","once","off","on"];analytics.factory=function(t){return function(){var e=Array.prototype.slice.call(arguments);e.unshift(t);analytics.push(e);return analytics}};for(var t=0;t<analytics.methods.length;t++){var e=analytics.methods[t];analytics[e]=analytics.factory(e)}analytics.load=function(t){var e=document.createElement("script");e.type="text/javascript";e.async=!0;e.src=("https:"===document.location.protocol?"https://":"http://")+"cdn.segment.com/analytics.js/v1/"+t+"/analytics.min.js";var n=document.getElementsByTagName("script")[0];n.parentNode.insertBefore(e,n)};analytics.SNIPPET_VERSION="3.0.1";
      analytics.load("#{@key}");
      analytics.page()
      }}();
      EOD
    end

    def identify(identity = nil)
      if identity.present? && identity.has_key?(:id)
        %Q{analytics.identify('#{identity[:id]}');}
      elsif identity.present?
        %Q{analytics.identify(#{ruby_hash_to_js(identity)});}
      else
        nil
      end
    end

    def create_alias(identity1, identity2)
      %Q{analytics.alias('#{identity1}', '#{identity2}');}
    end

    def add_properties(properties = nil)
      %Q{analytics.track('set', #{ruby_hash_to_js(properties)});}
    end

    def track_pageview(name = nil, category = nil, properties = {}, options = {})
      p = properties.empty? ? "" : ", #{ruby_hash_to_js(properties)}"
      if category.present? && name.present?
        %Q{analytics.page('#{category}', '#{name}'#{p});}
      elsif name.present?
        %Q{analytics.page('#{name}'#{p});}
      else
        %Q{analytics.page('');}
      end
    end

    def track_event(event_name, properties)
      p = properties.empty? ? "" : ", #{ruby_hash_to_js(properties.except(:analytics))}"
      %Q{analytics.track('#{event_name}'#{p});}
    end

    def track_transaction(event_name, properties = {})
      track_event(event_name, properties)
    end

    def identify_for_identity(identity, with_info = false)
      return if EventTracker.disabled?
      if identity.present? && identity.has_key?(:id)
        client.identify({
            user_id: "#{identity[:id]}",
        }.merge_if(with_info, { traits: camelize_hash(identity.except(:id)) }))
      end
    end

    def create_alias_for_identity(identity1, identity2)
      return if EventTracker.disabled?
      if identity1.present? && identity2.present?
        client.alias(from: identity1, to: identity2)
      end
    end

    def track_event_for_identity(identity, event_name, properties = {})
      return if EventTracker.disabled?
      if identity.present? && identity.has_key?(:id)
        client.track(
            user_id: "#{identity[:id]}",
            event: "#{event_name}",
            properties: camelize_hash(properties.except(:analytics))
        )
      end
    end

    def track_transaction_for_identity(identity, event_name, properties = {})
      track_event_for_identity(identity, event_name, properties)
    end

    private

    def camelize_hash(hash)
      Hash[hash.map { |k, v| [k.to_s.camelize(:lower), v] }]
    end

    def ruby_hash_to_js(hash)
      "{#{hash.collect{|key, val| "#{key.to_s.camelize(:lower)}: #{value_for_js(val)}" }.join(', ')}}"
    end

    def value_for_js(value)
      case value
        when Numeric, TrueClass, FalseClass
          value
        else
          "'#{escape_javascript(value.try(:to_s))}'"
      end
    end

    def escape_javascript(javascript)
      if javascript
        javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"'])/u) {|match| JS_ESCAPE_MAP[match] }
      else
        ''
      end
    end

    def client
      AnalyticsRuby
    end
  end
end
