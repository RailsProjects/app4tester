class Receipt < ActiveRecord::Base
  attr_accessible :en_actual_cost_in_cents, :en_coupon_name, :en_regular_cost_in_cents, :events_number, :sub_actual_monthly_cost_in_cents, :sub_coupon_name, :sub_events_number, :sub_my_plan_id, :sub_plan_name, :sub_reg_monthly_cost_in_cents, :subscription_id, :user_id, :email, :customer_id, :sub_reg_annual_cost_in_cents, :sub_actual_annual_cost_in_cents, :unlimited
end
