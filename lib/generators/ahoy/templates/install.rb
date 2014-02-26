class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :ahoy_visits do |t|
      t.string :visit_token
      t.string :visitor_token
      t.integer :user_id
      t.string :user_type
      t.string :ip
      t.text :user_agent

      # acquisition
      t.text :referrer
      t.string :referring_domain
      t.string :campaign
      # t.string :social_network
      # t.string :search_engine
      # t.string :search_keyword
      t.text :landing_page

      # technology
      t.string :browser
      t.string :os
      t.string :device_type

      # location
      t.string :country
      t.string :region
      t.string :city

      t.timestamp :created_at
    end

    add_index :ahoy_visits, [:visit_token], unique: true
    add_index :ahoy_visits, [:user_id, :user_type]
  end
end
