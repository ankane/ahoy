ActiveRecord::Schema.define do
  create_table :text_events, force: true do |t|
    t.string :name
    t.text :properties
  end
end

class SqliteBase < ActiveRecord::Base
  include Ahoy::QueryMethods
  self.abstract_class = true
end
