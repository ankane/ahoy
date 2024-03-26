require_relative "query_methods_helper"

class PostgresqlTextEvent < PostgresqlBase
  if ActiveRecord::VERSION::STRING.to_f >= 7.1
    serialize :properties, coder: JSON
  else
    serialize :properties, JSON
  end
end

class PostgresqlTextTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlTextEvent
  end
end
