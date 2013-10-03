class AddSaltToUsers < ActiveRecord::Migration
  def change
    add_column :users, :salt, :float8
  end
end
