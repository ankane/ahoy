require_relative "../test_helper"

ActiveRecord::Base.establish_connection adapter: "postgresql", database: "ahoy_test"

ActiveRecord::Migration.enable_extension "hstore"

ActiveRecord::Migration.create_table :postgresql_hstore_events, force: true do |t|
  t.hstore :properties
end

class PostgresqlHstoreEvent < PostgresqlBase
end

class PostgresqlHstoreTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlHstoreEvent
  end
end
