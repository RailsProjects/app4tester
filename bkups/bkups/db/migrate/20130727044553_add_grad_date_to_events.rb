class AddGradDateToEvents < ActiveRecord::Migration
  def change
    add_column :events, :grad_date, :string
  end
end
