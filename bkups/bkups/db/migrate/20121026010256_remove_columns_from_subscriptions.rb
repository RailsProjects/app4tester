class RemoveColumnsFromSubscriptions < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :plan_id
    remove_column :subscriptions, :customer_id
  end

  def down
    add_column :subscriptions, :customer_id, :string
    add_column :subscriptions, :plan_id, :string
  end
end
