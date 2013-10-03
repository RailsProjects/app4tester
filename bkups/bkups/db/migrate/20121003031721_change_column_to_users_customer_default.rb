class ChangeColumnToUsersCustomerDefault < ActiveRecord::Migration
  def up
  	change_column :users, :customer, :boolean, :default => false
  end

  def down
  	change_column :users, :customer, :boolean, :default => nil
  end
end
