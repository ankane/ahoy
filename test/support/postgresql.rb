ActiveRecord::Schema.define do
  enable_extension "hstore"

  create_table :postgresql_hstore_events, force: true do |t|
    t.string :name
    t.hstore :properties
  end

  create_table :postgresql_json_events, force: true do |t|
    t.string :name
    t.json :properties
  end

  create_table :postgresql_jsonb_events, force: true do |t|
    t.string :name
    t.jsonb :properties
    t.index :properties, using: :gin
  end

  create_table :postgresql_text_events, force: true do |t|
    t.string :name
    t.text :properties
  end
end

class PostgresqlBase < ActiveRecord::Base
  include Ahoy::QueryMethods
  self.abstract_class = true
end
