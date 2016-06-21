require_relative "../test_helper"

ActiveRecord::Base.establish_connection adapter: "mysql2", username: "root", database: "ahoy_test"

ActiveRecord::Migration.create_table :mysql_json_events, force: true do |t|
  t.json :properties
end

class MysqlJsonEvent < MysqlBase
end

class MysqlJsonTest < Minitest::Test
  include PropertiesTest

  def model
    MysqlJsonEvent
  end
end
