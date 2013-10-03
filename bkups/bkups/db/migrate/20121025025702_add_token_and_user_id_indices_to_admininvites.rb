class AddTokenAndUserIdIndicesToAdmininvites < ActiveRecord::Migration
  def change
  	add_index :admininvites, :user_id
    add_index :admininvites, :token
  end
end
