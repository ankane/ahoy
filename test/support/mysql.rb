ActiveRecord::Schema.define do
  create_table :mysql_text_events, force: true do |t|
    t.string :name
    t.text :properties
  end

  create_table :mysql_json_events, force: true do |t|
    t.string :name
    t.json :properties
  end
end

class MysqlBase < ActiveRecord::Base
  include Ahoy::QueryMethods
  self.abstract_class = true
end
