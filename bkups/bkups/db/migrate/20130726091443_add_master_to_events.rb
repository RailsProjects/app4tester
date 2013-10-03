class AddMasterToEvents < ActiveRecord::Migration
  def change
    add_column :events, :master, :boolean
  end
end
