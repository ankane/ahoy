require_relative "test_helper"

require "generators/ahoy/activerecord_generator"

class ActiverecordGeneratorTest < Rails::Generators::TestCase
  tests Ahoy::Generators::ActiverecordGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_works
    skip if ENV["ADAPTER"] == "mongoid"

    run_generator
    assert_file "config/initializers/ahoy.rb"
    assert_file "app/models/ahoy/visit.rb"
    assert_file "app/models/ahoy/event.rb"
    assert_migration "db/migrate/create_ahoy_visits_and_events.rb"
  end
end
