require 'spec_helper'

describe "receipts/edit" do
  before(:each) do
    @receipt = assign(:receipt, stub_model(Receipt,
      :user_id => 1,
      :subscription_id => 1,
      :sub_my_plan_id => 1,
      :sub_plan_name => "MyString",
      :sub_events_number => 1,
      :sub_reg_monthly_cost_in_cents => 1,
      :sub_actual_monthly_cost_in_cents => 1,
      :sub_coupon_name => "MyString",
      :events_number => 1,
      :en_regular_cost_in_cents => 1,
      :en_actual_cost_in_cents => 1,
      :en_coupon_name => "MyString"
    ))
  end

  it "renders the edit receipt form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => receipts_path(@receipt), :method => "post" do
      assert_select "input#receipt_user_id", :name => "receipt[user_id]"
      assert_select "input#receipt_subscription_id", :name => "receipt[subscription_id]"
      assert_select "input#receipt_sub_my_plan_id", :name => "receipt[sub_my_plan_id]"
      assert_select "input#receipt_sub_plan_name", :name => "receipt[sub_plan_name]"
      assert_select "input#receipt_sub_events_number", :name => "receipt[sub_events_number]"
      assert_select "input#receipt_sub_reg_monthly_cost_in_cents", :name => "receipt[sub_reg_monthly_cost_in_cents]"
      assert_select "input#receipt_sub_actual_monthly_cost_in_cents", :name => "receipt[sub_actual_monthly_cost_in_cents]"
      assert_select "input#receipt_sub_coupon_name", :name => "receipt[sub_coupon_name]"
      assert_select "input#receipt_events_number", :name => "receipt[events_number]"
      assert_select "input#receipt_en_regular_cost_in_cents", :name => "receipt[en_regular_cost_in_cents]"
      assert_select "input#receipt_en_actual_cost_in_cents", :name => "receipt[en_actual_cost_in_cents]"
      assert_select "input#receipt_en_coupon_name", :name => "receipt[en_coupon_name]"
    end
  end
end
