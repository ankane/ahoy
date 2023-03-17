class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true

  if ActiveRecord::VERSION::STRING.to_f >= 7.1
    serialize :properties, coder: JSON
  else
    serialize :properties, JSON
  end
end
