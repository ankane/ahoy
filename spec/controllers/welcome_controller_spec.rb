require 'spec_helper'

describe WelcomeController, :type => :controller do
  context "GET index" do
    it "assert ahoy_events count changed" do
      expect { get :index }.to change{Ahoy::Event.count}.by(1)
    end
  end
end
