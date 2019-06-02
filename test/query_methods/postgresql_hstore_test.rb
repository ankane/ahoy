require_relative "../test_helper"

class PostgresqlHstoreEvent < PostgresqlBase
end

class PostgresqlHstoreTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlHstoreEvent
  end
end
