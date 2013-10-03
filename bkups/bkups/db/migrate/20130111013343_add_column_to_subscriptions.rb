class AddColumnToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :events_used, :integer, :default => 0
  end
end
