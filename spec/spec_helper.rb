require 'bundler'

# If you're using all parts of Rails:
# Or, load just what you need:
# Combustion.initialize! :active_record, :action_controller
require 'combustion'
Combustion.initialize! :active_record, :active_support, :active_job

require 'rspec/rails'
Bundler.require :default, :development
# If you're using Capybara:
# require 'capybara/rails'
RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
include FactoryBot::Syntax::Methods
