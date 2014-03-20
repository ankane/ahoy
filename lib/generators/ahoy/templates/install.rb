class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      # cookies *required*
      t.string :visit_token
      t.string :visitor_token

      # the rest are recommended but optional
      # simply remove the columns you don't want

      # standard
      t.string :ip
      t.text :user_agent
      t.text :referrer
      t.text :landing_page

      # user
      t.integer :user_id
      t.string :user_type

      # traffic source
      t.string :referring_domain
      t.string :search_keyword

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

    add_index :visits, [:visit_token], unique: true
    add_index :visits, [:user_id, :user_type]
  end
end
