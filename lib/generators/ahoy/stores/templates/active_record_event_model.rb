module Ahoy
  class Event < ActiveRecord::Base
    self.table_name = "ahoy_events"

    belongs_to :visit
    belongs_to :user<% if options["database"] != "postgresql" %>

    serialize :properties, JSON<% end %>
  end
end
