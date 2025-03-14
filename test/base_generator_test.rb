require_relative "test_helper"

require "generators/ahoy/base_generator"

class BaseGeneratorTest < Rails::Generators::TestCase
  tests Ahoy::Generators::BaseGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_works
    run_generator
    assert_file "config/initializers/ahoy.rb", /BaseStore/
  end
end
