class AddUnlimitedColumnToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :sub_reg_annual_cost_in_cents, :integer
    add_column :receipts, :sub_actual_annual_cost_in_cents, :integer
    add_column :receipts, :unlimited, :boolean
  end
end
