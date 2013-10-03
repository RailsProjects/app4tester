class ChangeDefaultOnSubscriptionEventsRemaining < ActiveRecord::Migration
  def change
  	change_column :subscriptions, :events_remaining, :integer, :default => 0
  end
end
