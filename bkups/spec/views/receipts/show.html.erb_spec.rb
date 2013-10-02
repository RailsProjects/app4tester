require 'spec_helper'

describe "receipts/show" do
  before(:each) do
    @receipt = assign(:receipt, stub_model(Receipt,
      :user_id => 1,
      :subscription_id => 2,
      :sub_my_plan_id => 3,
      :sub_plan_name => "Sub Plan Name",
      :sub_events_number => 4,
      :sub_reg_monthly_cost_in_cents => 5,
      :sub_actual_monthly_cost_in_cents => 6,
      :sub_coupon_name => "Sub Coupon Name",
      :events_number => 7,
      :en_regular_cost_in_cents => 8,
      :en_actual_cost_in_cents => 9,
      :en_coupon_name => "En Coupon Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/Sub Plan Name/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
    rendered.should match(/Sub Coupon Name/)
    rendered.should match(/7/)
    rendered.should match(/8/)
    rendered.should match(/9/)
    rendered.should match(/En Coupon Name/)
  end
end
