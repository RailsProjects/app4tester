class AddColumnToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :my_plan_id, :integer
  end
end
