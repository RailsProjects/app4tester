class AddColumnToAdmininvites < ActiveRecord::Migration
  def change
    add_column :admininvites, :admin_id, :integer
    add_column :admininvites, :user_id, :integer
  end
end
