class AddColumnsToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :customer_id, :integer
    add_column :subscriptions, :plan_id, :integer
  end
end
