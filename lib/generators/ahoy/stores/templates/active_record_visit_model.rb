class Visit < ActiveRecord::Base
  has_many :ahoy_events, class_name: "Ahoy::Event"
  belongs_to :user<%= Rails::VERSION::MAJOR >= 5 ? ", optional: true" : nil %>
end
