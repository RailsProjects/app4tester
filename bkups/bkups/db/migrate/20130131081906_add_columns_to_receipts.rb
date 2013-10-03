class AddColumnsToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :email, :string
    add_column :receipts, :customer_id, :string
  end
end
