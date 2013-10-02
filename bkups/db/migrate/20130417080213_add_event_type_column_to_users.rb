class AddEventTypeColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :event_type, :string
  end
end
