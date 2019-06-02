ActiveRecord::Base.establish_connection adapter: "postgresql", database: "ahoy_test"

ActiveRecord::Migration.enable_extension "hstore"

ActiveRecord::Migration.create_table :postgresql_hstore_events, force: true do |t|
  t.hstore :properties
end

ActiveRecord::Migration.create_table :postgresql_json_events, force: true do |t|
  t.json :properties
end

ActiveRecord::Migration.create_table :postgresql_jsonb_events, force: true do |t|
  t.jsonb :properties
  t.index :properties, using: :gin
end

ActiveRecord::Migration.create_table :postgresql_text_events, force: true do |t|
  t.text :properties
end

class PostgresqlBase < ActiveRecord::Base
  include Ahoy::QueryMethods
  establish_connection adapter: "postgresql", database: "ahoy_test"
  self.abstract_class = true
end
