warn "[DEPRECATION] Loading Ahoy::Event from the engine is deprecated"

module Ahoy
  class Event < ActiveRecord::Base
    self.table_name = "ahoy_events"

    belongs_to :visit
    belongs_to :user, polymorphic: true

    serialize :properties, JSON
  end
end
