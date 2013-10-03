class AddMoreColumnsToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :my_plan_id, :integer
    add_column :subscriptions, :plan_name, :string
  end
end
