require_relative "../test_helper"

class MongoidEvent
  include Mongoid::Document
  include Ahoy::QueryMethods

  field :properties, type: Hash
end

class MongoidTest < Minitest::Test
  include QueryMethodsTest

  def setup
    if Rails::VERSION::MAJOR == 6
      @@once ||= begin
        warn "Cannot test Rails 6 + Mongoid due to segmentation fault"
        true
      end
      skip
    end
    super
  end

  def model
    MongoidEvent
  end
end
