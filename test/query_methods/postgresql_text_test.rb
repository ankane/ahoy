require_relative "query_methods_helper"

class PostgresqlTextEvent < PostgresqlBase
  serialize :properties, JSON
end

class PostgresqlTextTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlTextEvent
  end
end
