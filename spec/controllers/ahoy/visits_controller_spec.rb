require 'spec_helper'

describe Ahoy::VisitsController, :type => :controller do
  routes { Ahoy::Engine.routes }

  it "creates visits" do
    begin
      previous_value = Ahoy.track_visits_immediately = true

      expect { post :create }.to change{ Visit.count }.by(1)
    ensure
      Ahoy.track_visits_immediately = previous_value
    end
  end

  it "renders JSON hash with visitor_id and visit_id" do
    post :create, :format => :json
    response_hash = ActiveSupport::JSON.decode(response.body)
    expect(response_hash).to have_key("visit_id")
    expect(response_hash).to have_key("visitor_id")
  end
end
