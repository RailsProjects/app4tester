class AddTokenIndicesToUsers < ActiveRecord::Migration
  def change
  	add_index :users, :password_reset_token
    add_index :users, :remember_token
  end
end
