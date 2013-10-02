require 'spec_helper'

describe "receipts/index" do
  before(:each) do
    assign(:receipts, [
      stub_model(Receipt,
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
      ),
      stub_model(Receipt,
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
      )
    ])
  end

  it "renders a list of receipts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Sub Plan Name".to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
    assert_select "tr>td", :text => "Sub Coupon Name".to_s, :count => 2
    assert_select "tr>td", :text => 7.to_s, :count => 2
    assert_select "tr>td", :text => 8.to_s, :count => 2
    assert_select "tr>td", :text => 9.to_s, :count => 2
    assert_select "tr>td", :text => "En Coupon Name".to_s, :count => 2
  end
end
