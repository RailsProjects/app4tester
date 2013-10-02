class AddCouponToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :coupon, :string
  end
end
