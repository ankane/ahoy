require_relative "test_helper"

require "generators/ahoy/mongoid_generator"

class MongoidGeneratorTest < Rails::Generators::TestCase
  tests Ahoy::Generators::MongoidGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_works
    run_generator
    assert_file "config/initializers/ahoy.rb", /DatabaseStore/
    assert_file "app/models/ahoy/visit.rb", /Mongoid::Document/
    assert_file "app/models/ahoy/event.rb", /Mongoid::Document/
  end
end
