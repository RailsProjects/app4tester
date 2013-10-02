require 'spec_helper'

describe "coupons/show" do
  before(:each) do
    @coupon = assign(:coupon, stub_model(Coupon,
      :name => "Name",
      :percent_off => 1,
      :max_redemptions => 2,
      :duration => "Duration",
      :duration_in_months => 3,
      :times_redeemed => 4,
      :free_page_name => "Free Page Name",
      :free_page_user => 5,
      :active => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Duration/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/Free Page Name/)
    rendered.should match(/5/)
    rendered.should match(/false/)
  end
end
