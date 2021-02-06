require_relative "query_methods_helper"

class PostgresqlJsonEvent < PostgresqlBase
end

class PostgresqlJsonTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlJsonEvent
  end
end
