class AddColumnsToSubscriptionsAgain < ActiveRecord::Migration
  def change
    add_column :subscriptions, :plan_id, :string
    add_column :subscriptions, :customer_id, :string
  end
end
