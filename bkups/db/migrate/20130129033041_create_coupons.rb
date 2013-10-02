class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :name, :default => 'single_use'
      t.integer :percent_off
      t.integer :max_redemptions
      t.string :duration
      t.integer :duration_in_months
      t.datetime :redeem_by
      t.integer :times_redeemed
      t.string :free_page_name
      t.integer :free_page_user
      t.boolean :active

      t.timestamps
    end
  end
end
