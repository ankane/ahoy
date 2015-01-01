ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment', __FILE__)

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
