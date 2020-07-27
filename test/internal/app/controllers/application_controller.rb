class ApplicationController < ActionController::Base
  attr_accessor :ran_before_action
  before_action :run_before_action

  def run_before_action
    self.ran_before_action = true
  end
end
