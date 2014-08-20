class EventsController < ApplicationController
  def index
    track_event('List events')
  end
end