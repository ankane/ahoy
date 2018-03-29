# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :ahoy_visits do |t|
     t.string :visit_token
     t.string :visitor_token

     # the rest are recommended but optional
     # simply remove any you don't want

     # user
     t.references :user

     # standard
     t.string :ip
     t.text :user_agent
     t.text :referrer
     t.string :referring_domain
     t.string :search_keyword
     t.text :landing_page

     # technology
     t.string :browser
     t.string :os
     t.string :device_type

     # location
     t.string :country
     t.string :region
     t.string :city

     # utm parameters
     t.string :utm_source
     t.string :utm_medium
     t.string :utm_term
     t.string :utm_content
     t.string :utm_campaign

     t.timestamp :started_at
   end

   add_index :ahoy_visits, [:visit_token], unique: true

   create_table :ahoy_events do |t|
     t.references :visit
     t.references :user

     t.string :name
     t.json :properties
     t.timestamp :time
   end

   add_index :ahoy_events, [:name, :time]
end
