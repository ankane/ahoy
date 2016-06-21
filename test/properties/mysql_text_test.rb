require_relative "../test_helper"

ActiveRecord::Base.establish_connection adapter: "mysql2", username: "root", database: "ahoy_test"

ActiveRecord::Migration.create_table :mysql_text_events, force: true do |t|
  t.text :properties
end

class MysqlTextEvent < MysqlBase
  serialize :properties, JSON
end

class MysqlTextTest < Minitest::Test
  include PropertiesTest

  def model
    MysqlTextEvent
  end
end
