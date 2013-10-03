class AddVgColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :vg_notes, :text
    add_column :users, :vg_request, :string
  end
end
