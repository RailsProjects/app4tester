class RemoveColumnFromAdmininvites < ActiveRecord::Migration
  def up
    remove_column :admininvites, :admin_id
    remove_column :admininvites, :user_id
  end

  def down
    add_column :admininvites, :user_id, :string
    add_column :admininvites, :admin_id, :string
  end
end
