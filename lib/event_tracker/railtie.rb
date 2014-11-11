module EventTracker
  class Railtie < ::Rails::Railtie

    initializer 'event_tracker' do |_app|
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, EventTracker::ActionControllerExtension)
        ActionController::Base.send(:include, EventTracker::HelperMethods)
        ActionController::Base.send(:helper, EventTracker::HelperMethods)
      end
    end
  end
end