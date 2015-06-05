require 'event-tracker'

ActionController::Base.send(:include, EventTracker::ActionControllerExtension)
ActionController::Base.send(:include, EventTracker::HelperMethods)
ActionController::Base.send(:helper, EventTracker::HelperMethods)

EventTracker.configure do |config|
  config.segment_io_key = 'dummy'
  config.disabled = false
end