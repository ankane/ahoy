class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :ahoy_events, id: false do |t|
      <% if options["database"] == "postgresql" %>t.uuid :id, primary_key: true
      t.uuid :visit_id<% else %>t.binary :id, limit: 16, primary_key: true
      t.binary :visit_id, limit: 16<% end %>

      # user
      t.integer :user_id
      # add t.string :user_type if polymorphic

      t.string :name
      t.<% if options["database"] == "postgresql" %>json<% else %>text<% end %> :properties
      t.timestamp :time
    end

    add_index :ahoy_events, [:visit_id]
    add_index :ahoy_events, [:user_id]
    add_index :ahoy_events, [:time]
  end
end
