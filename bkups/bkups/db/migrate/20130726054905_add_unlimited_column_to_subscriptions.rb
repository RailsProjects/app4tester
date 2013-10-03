class AddUnlimitedColumnToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :unlimited, :boolean
  end
end
