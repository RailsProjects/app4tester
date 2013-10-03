class AddColumnToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :redeemed_on, :datetime, :default => nil
    change_column :coupons, :redeem_by, :datetime, :default => nil
  end
end
