require 'spec_helper'

describe "coupons/new" do
  before(:each) do
    assign(:coupon, stub_model(Coupon,
      :name => "MyString",
      :percent_off => 1,
      :max_redemptions => 1,
      :duration => "MyString",
      :duration_in_months => 1,
      :times_redeemed => 1,
      :free_page_name => "MyString",
      :free_page_user => 1,
      :active => false
    ).as_new_record)
  end

  it "renders new coupon form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => coupons_path, :method => "post" do
      assert_select "input#coupon_name", :name => "coupon[name]"
      assert_select "input#coupon_percent_off", :name => "coupon[percent_off]"
      assert_select "input#coupon_max_redemptions", :name => "coupon[max_redemptions]"
      assert_select "input#coupon_duration", :name => "coupon[duration]"
      assert_select "input#coupon_duration_in_months", :name => "coupon[duration_in_months]"
      assert_select "input#coupon_times_redeemed", :name => "coupon[times_redeemed]"
      assert_select "input#coupon_free_page_name", :name => "coupon[free_page_name]"
      assert_select "input#coupon_free_page_user", :name => "coupon[free_page_user]"
      assert_select "input#coupon_active", :name => "coupon[active]"
    end
  end
end
