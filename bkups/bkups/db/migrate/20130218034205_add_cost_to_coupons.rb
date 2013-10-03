class AddCostToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :cost, :integer
  end
end
