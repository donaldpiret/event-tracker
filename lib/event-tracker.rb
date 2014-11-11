module EventTracker
end

begin
  require 'rails'
rescue LoadError
  #do nothing
end

require 'core_ext/hash'

require 'event_tracker/config'
require 'event_tracker/tracker'
require 'event_tracker/helper_methods'
require 'event_tracker/action_controller_extensions'
require 'event_tracker/segment_io'

if defined? Rails
  require 'event_tracker/railtie'
end
