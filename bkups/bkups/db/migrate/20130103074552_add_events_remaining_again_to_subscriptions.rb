class AddEventsRemainingAgainToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :events_remaining, :integer, :default => 0
  end
end
