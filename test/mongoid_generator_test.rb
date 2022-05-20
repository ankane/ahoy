require_relative "test_helper"

require "generators/ahoy/mongoid_generator"

class MongoidGeneratorTest < Rails::Generators::TestCase
  tests Ahoy::Generators::MongoidGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_works
    run_generator
    assert_file "config/initializers/ahoy.rb"
    assert_file "app/models/ahoy/visit.rb"
    assert_file "app/models/ahoy/event.rb"
  end
end
