class Ahoy::Visit < <%= rails5? ? "ApplicationRecord" : "ActiveRecord::Base" %>
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user<%= rails5? ? ", optional: true" : nil %>
end
