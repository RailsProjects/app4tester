class AddAnnualCostInCentsToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :annual_cost_cents, :integer
  end
end
