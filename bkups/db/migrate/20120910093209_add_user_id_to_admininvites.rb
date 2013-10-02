class AddUserIdToAdmininvites < ActiveRecord::Migration
  def change
    add_column :admininvites, :user_id, :string
  end
end
