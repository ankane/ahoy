require_relative "query_methods_helper"

class MongoidEvent
  include Mongoid::Document
  include Ahoy::QueryMethods

  field :name, type: String
  field :properties, type: Hash
end

class MongoidTest < Minitest::Test
  include QueryMethodsTest

  def model
    MongoidEvent
  end
end
