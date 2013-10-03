class ChangeColumnToCoupons < ActiveRecord::Migration
  def change
  	change_column :coupons, :active, :boolean, :default => true
  end
end
