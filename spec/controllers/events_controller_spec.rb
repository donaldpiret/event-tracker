require 'spec_helper'

describe EventsController, type: :controller do
  render_views

  describe '#index' do
    it 'includes the segment.io javascript in the user browser' do
      get :index
      expect(response.body).to include('cdn.segment.com/analytics.js/v1/') # Invluding the JS
    end

    it 'identifies the user for segment.io' do
      get :index
      expect(response.body).to include('analytics.identify(\'dummyId\');') # Identifying the user
    end

    it 'tracks the event for segment.io' do
      get :index
      expect(response.body).to include('analytics.track(\'List events\');') # Tracking the event
    end
  end
end