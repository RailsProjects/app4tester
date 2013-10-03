class AddEventsRemainingToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :events_remaining, :integer
  end
end
