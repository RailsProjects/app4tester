class RemoveColumnFromSubscriptions < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :customer_id
    remove_column :subscriptions, :plan_id
  end

  def down
    add_column :subscriptions, :plan_id, :string
    add_column :subscriptions, :customer_id, :string
  end
end
