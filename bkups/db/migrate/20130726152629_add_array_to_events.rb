class AddArrayToEvents < ActiveRecord::Migration
  def change
    add_column :events, :grad_array, :text
  end
end
