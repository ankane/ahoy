class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :ahoy_visits do |t|
      # cookies
      t.string :visit_token
      t.string :visitor_token

      # standard
      t.string :ip
      t.text :user_agent

      # user
      t.integer :user_id
      t.string :user_type

      # traffic source
      t.text :referrer
      t.string :referring_domain
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

      t.timestamp :created_at
    end

    add_index :ahoy_visits, [:visit_token], unique: true
    add_index :ahoy_visits, [:user_id, :user_type]
  end
end
