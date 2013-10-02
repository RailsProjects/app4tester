class RemoveAdminIdFromAdminkeys < ActiveRecord::Migration
  def up
    remove_column :adminkeys, :admin_id
  end

  def down
    add_column :adminkeys, :admin_id, :integer
  end
end
