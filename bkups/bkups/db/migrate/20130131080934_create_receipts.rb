class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.integer :user_id
      t.integer :subscription_id
      t.integer :sub_my_plan_id
      t.string :sub_plan_name
      t.integer :sub_events_number
      t.integer :sub_reg_monthly_cost_in_cents
      t.integer :sub_actual_monthly_cost_in_cents
      t.string :sub_coupon_name
      t.integer :events_number
      t.integer :en_regular_cost_in_cents
      t.integer :en_actual_cost_in_cents
      t.string :en_coupon_name

      t.timestamps
    end
  end
end
