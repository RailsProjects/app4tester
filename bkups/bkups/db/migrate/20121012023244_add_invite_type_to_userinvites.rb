class AddInviteTypeToUserinvites < ActiveRecord::Migration
  def change
    add_column :userinvites, :invite_type, :string
  end
end
