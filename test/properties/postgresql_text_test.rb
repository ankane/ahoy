require_relative "../test_helper"

ActiveRecord::Base.establish_connection adapter: "postgresql", database: "ahoy_test"

ActiveRecord::Migration.create_table :postgresql_text_events, force: true do |t|
  t.text :properties
end

class PostgresqlTextEvent < PostgresqlBase
  serialize :properties, JSON
end

class PostgresqlTextTest < Minitest::Test
  include PropertiesTest

  def model
    PostgresqlTextEvent
  end
end
