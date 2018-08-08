class Ahoy::Event < <%= rails5? ? "ApplicationRecord" : "ActiveRecord::Base" %>
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user<%= rails5? ? ", optional: true" : nil %><% if properties_type == "text" %>

  serialize :properties, JSON<% end %>
end
