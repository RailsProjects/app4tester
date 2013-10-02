class AddIndicesToCustomerkeysUserEventCombo < ActiveRecord::Migration
  def change
  	add_index :customerkeys, :user_id
    add_index :customerkeys, :event_id
  	add_index :customerkeys, [:user_id, :event_id], unique: true
  end
end
