class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :email
      t.string :customer_id
      t.string :plan_id
      t.datetime :canceled_at
      t.boolean :active

      t.timestamps
    end
  end
end
