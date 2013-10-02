class AddPurchasedEventsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :purchased_events, :integer, :default => 0
  end
end
