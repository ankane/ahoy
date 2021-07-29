ActiveRecord::Base.establish_connection adapter: "mysql2", database: "ahoy_test"

ActiveRecord::Schema.define do
  create_table :mysql_text_events, force: true do |t|
    t.text :properties
  end

  create_table :mysql_json_events, force: true do |t|
    t.json :properties
  end
end

class MysqlBase < ActiveRecord::Base
  include Ahoy::QueryMethods
  establish_connection adapter: "mysql2", database: "ahoy_test"
  self.abstract_class = true
end
