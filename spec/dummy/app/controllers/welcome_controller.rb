class WelcomeController < ApplicationController
  def index
  	ahoy.track "Viewed book", title: "Hot, Flat, and Crowded"
  end
end
