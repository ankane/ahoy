require_relative "../test_helper"

ActiveRecord::Base.establish_connection adapter: "postgresql", database: "ahoy_test"

ActiveRecord::Migration.create_table :postgresql_json_events, force: true do |t|
  t.json :properties
end

class PostgresqlJsonEvent < PostgresqlBase
end

class PostgresqlJsonTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlJsonEvent
  end
end
