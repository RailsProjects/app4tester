class RemoveEventsRemainingFromSubscriptions < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :events_remaining
  end

  def down
    add_column :subscriptions, :events_remaining, :integer
  end
end
