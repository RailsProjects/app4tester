class AddGradDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :grad_date, :string
  end
end
