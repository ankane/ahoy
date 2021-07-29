ActiveRecord::Base.establish_connection adapter: "postgresql", database: "ahoy_test"

ActiveRecord::Schema.define do
  enable_extension "hstore"

  create_table :postgresql_hstore_events, force: true do |t|
    t.hstore :properties
  end

  create_table :postgresql_json_events, force: true do |t|
    t.json :properties
  end

  create_table :postgresql_jsonb_events, force: true do |t|
    t.jsonb :properties
    t.index :properties, using: :gin
  end

  create_table :postgresql_text_events, force: true do |t|
    t.text :properties
  end
end

class PostgresqlBase < ActiveRecord::Base
  include Ahoy::QueryMethods
  establish_connection adapter: "postgresql", database: "ahoy_test"
  self.abstract_class = true
end
