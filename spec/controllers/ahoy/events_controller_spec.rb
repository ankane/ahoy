require 'spec_helper'

describe Ahoy::EventsController, :type => :controller do
  routes { Ahoy::Engine.routes }

  it "creates event with other attr" do
    time = (Time.now - 30).utc.change(:usec => 0)
    post :create, :id => "11111111-2222-3333-4444-555555555555",
      :name => "$submit",
      :properties => {"bar" => "baz"},
      :time => time
    event = Ahoy::Event.last
    expect(event.time).to eq(time)
    expect(event.id).to eq("11111111-2222-3333-4444-555555555555")
    expect(event.name).to eq("$submit")
    expect(event.properties).to eq({"bar" => "baz"})
  end

  it "creates event with passed name via json request" do
    json = [
      { :name => "JSON1", :properties => { "buzz" => "bazz"} },
      { :name => "JSON2", :properties => { "fuzz" => "fazz"} }
    ].to_json
    post :create, json, :format => :json
    last_two_events = Ahoy::Event.order('time DESC').limit(2)
    expect(last_two_events[0].name).to eq("JSON2")
    expect(last_two_events[1].name).to eq("JSON1")
  end

  it "renders an empty JSON response" do
    post :create, :id => "11111111-2222-3333-4444-555555555555",
      :name => "$submit",
      :properties => {"bar" => "baz"}
    expect(ActiveSupport::JSON.decode(response.body)).to eq({})
  end
end
