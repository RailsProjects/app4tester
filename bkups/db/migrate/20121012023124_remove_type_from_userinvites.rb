class RemoveTypeFromUserinvites < ActiveRecord::Migration
  def up
    remove_column :userinvites, :type
  end

  def down
    add_column :userinvites, :type, :string
  end
end
