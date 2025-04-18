require_relative "query_methods_helper"

class PostgresqlTextEvent < PostgresqlBase
  serialize :properties, coder: JSON
end

class PostgresqlTextTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlTextEvent
  end
end
