module Ahoy
  class Event < ActiveRecord::Base
    include Ahoy::Properties

    self.table_name = "ahoy_events"

    belongs_to :visit
    belongs_to :user<%= Rails::VERSION::MAJOR >= 5 ? ", optional: true" : nil %><% unless %w(postgresql postgresql-jsonb).include?(@database) %>

    serialize :properties, JSON<% end %>
  end
end
