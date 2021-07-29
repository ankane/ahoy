ActiveRecord::Base.establish_connection adapter: "mysql2", database: "ahoy_test"

# TODO use ActiveRecord::Schema.define when Active Record 5.0 is no longer supported
# https://github.com/rails/rails/issues/28730
ActiveRecord::Migration.create_table :mysql_text_events, force: true do |t|
  t.text :properties
end

ActiveRecord::Migration.create_table :mysql_json_events, force: true do |t|
  t.json :properties
end

class MysqlBase < ActiveRecord::Base
  include Ahoy::QueryMethods
  establish_connection adapter: "mysql2", database: "ahoy_test"
  self.abstract_class = true
end
