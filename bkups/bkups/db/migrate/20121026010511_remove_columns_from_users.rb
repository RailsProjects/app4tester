class RemoveColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :customer_id
  end

  def down
    add_column :users, :customer_id, :string
  end
end
