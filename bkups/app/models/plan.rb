class Plan < ActiveRecord::Base
  attr_accessible :events_number, :monthly_cost_cents, :name, :trial_period, :my_plan_id, :annual_cost_cents, :unlimited, :event_type

   default_scope order(:my_plan_id)
end
