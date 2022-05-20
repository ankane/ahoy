require_relative "test_helper"

require "generators/ahoy/activerecord_generator"

class ActiverecordGeneratorTest < Rails::Generators::TestCase
  tests Ahoy::Generators::ActiverecordGenerator
  destination File.expand_path("../tmp", __dir__)

  def test_works
    run_generator
    assert_file "config/initializers/ahoy.rb"
    assert_file "app/models/ahoy/visit.rb"
    assert_file "app/models/ahoy/event.rb"
  end
end
