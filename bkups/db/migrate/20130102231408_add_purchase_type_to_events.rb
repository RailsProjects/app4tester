class AddPurchaseTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :purchase_type, :string
  end
end
