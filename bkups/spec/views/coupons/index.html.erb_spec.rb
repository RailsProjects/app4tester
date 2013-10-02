require 'spec_helper'

describe "coupons/index" do
  before(:each) do
    assign(:coupons, [
      stub_model(Coupon,
        :name => "Name",
        :percent_off => 1,
        :max_redemptions => 2,
        :duration => "Duration",
        :duration_in_months => 3,
        :times_redeemed => 4,
        :free_page_name => "Free Page Name",
        :free_page_user => 5,
        :active => false
      ),
      stub_model(Coupon,
        :name => "Name",
        :percent_off => 1,
        :max_redemptions => 2,
        :duration => "Duration",
        :duration_in_months => 3,
        :times_redeemed => 4,
        :free_page_name => "Free Page Name",
        :free_page_user => 5,
        :active => false
      )
    ])
  end

  it "renders a list of coupons" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Duration".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "Free Page Name".to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
