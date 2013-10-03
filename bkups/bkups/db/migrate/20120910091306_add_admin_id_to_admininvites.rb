class AddAdminIdToAdmininvites < ActiveRecord::Migration
  def change
    add_column :admininvites, :admin_id, :string
  end
end
