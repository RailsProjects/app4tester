class AddIndexToAdminkeys < ActiveRecord::Migration
  def change
  	add_index :adminkeys, :user_id
    add_index :adminkeys, :event_id
  	add_index :adminkeys, [:user_id, :event_id], unique: true
  end
end
