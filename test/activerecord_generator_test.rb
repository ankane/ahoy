require_relative "test_helper"

require "generators/ahoy/activerecord_generator"

class ActiverecordGeneratorTest < Rails::Generators::TestCase
  tests Ahoy::Generators::ActiverecordGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def setup
    skip if ENV["ADAPTER"] == "mongoid"
    super
  end

  def test_works
    run_generator
    assert_file "config/initializers/ahoy.rb", /DatabaseStore/
    assert_file "app/models/ahoy/visit.rb", /Ahoy::Visit < ApplicationRecord/
    assert_file "app/models/ahoy/event.rb", /Ahoy::Event < ApplicationRecord/
    assert_migration "db/migrate/create_ahoy_visits_and_events.rb", /create_table/
  end

  def test_primary_key_type
    Rails.configuration.generators.stub(:options, {active_record: {primary_key_type: :uuid}}) do
      run_generator
    end
    assert_migration "db/migrate/create_ahoy_visits_and_events.rb", /id: :uuid/
    assert_migration "db/migrate/create_ahoy_visits_and_events.rb", /type: :uuid/
  end
end
