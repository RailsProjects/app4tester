class AddUnlimitedColumnToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :unlimited, :boolean
  end
end
