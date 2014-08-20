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
      window.analytics=window.analytics||[],window.analytics.methods=["identify","group","track","page","pageview","alias","ready","on","once","off","trackLink","trackForm","trackClick","trackSubmit"],window.analytics.factory=function(t){return function(){var a=Array.prototype.slice.call(arguments);return a.unshift(t),window.analytics.push(a),window.analytics}};for(var i=0;i<window.analytics.methods.length;i++){var key=window.analytics.methods[i];window.analytics[key]=window.analytics.factory(key)}window.analytics.load=function(t){if(!document.getElementById("analytics-js")){var a=document.createElement("script");a.type="text/javascript",a.id="analytics-js",a.async=!0,a.src=("https:"===document.location.protocol?"https://":"http://")+"cdn.segment.io/analytics.js/v1/"+t+"/analytics.min.js";var n=document.getElementsByTagName("script")[0];n.parentNode.insertBefore(a,n)}},window.analytics.SNIPPET_VERSION="2.0.9",
      window.analytics.load("#{@key}");
      window.analytics.page();
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
