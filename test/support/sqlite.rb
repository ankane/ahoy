ActiveRecord::Base.establish_connection adapter: "sqlite3", database: "/tmp/ahoy.sqlite3"

ActiveRecord::Schema.define do
  create_table :text_events, force: true do |t|
    t.text :properties
  end
end

class SqliteBase < ActiveRecord::Base
  include Ahoy::QueryMethods
  establish_connection adapter: "sqlite3", database: "/tmp/ahoy.sqlite3"
  self.abstract_class = true
end
