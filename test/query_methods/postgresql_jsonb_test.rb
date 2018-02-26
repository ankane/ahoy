require_relative "../test_helper"

ActiveRecord::Base.establish_connection adapter: "postgresql", database: "ahoy_test"

ActiveRecord::Migration.create_table :postgresql_jsonb_events, force: true do |t|
  t.jsonb :properties
  t.index :properties, using: 'gin'
end

class PostgresqlJsonbEvent < PostgresqlBase
end

class PostgresqlJsonbTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlJsonbEvent
  end
end
