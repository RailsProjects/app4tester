class AddTypeToUserinvites < ActiveRecord::Migration
  def change
    add_column :userinvites, :type, :string
  end
end
