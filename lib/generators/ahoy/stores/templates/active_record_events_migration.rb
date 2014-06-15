class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :ahoy_events do |t|
      # visit
      t.references :visit

      # user
      t.integer :user_id
      t.string :user_type

      t.string :name
      t.text :properties
      # use t.json :properties for PostreSQL 9.2+
      t.timestamp :time
    end

    add_index :ahoy_events, [:visit_id]
    add_index :ahoy_events, [:user_id, :user_type]
    add_index :ahoy_events, [:time]
  end
end
