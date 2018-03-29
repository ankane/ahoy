ENV['RAILS_ENV'] = 'test'

require 'bundler'

Bundler.require :default, :development

# If you're using all parts of Rails:
Combustion.initialize! :all
# Or, load just what you need:
# Combustion.initialize! :active_record, :action_controller

require 'rspec/rails'
# If you're using Capybara:
# require 'capybara/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
