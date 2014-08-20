class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :append_tracker

  def analytics_identity(user = nil)
    { id: 'dummyId' }
  end
end
