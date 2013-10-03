class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :events_number
      t.integer :trial_period
      t.integer :monthly_cost_cents

      t.timestamps
    end
  end
end
