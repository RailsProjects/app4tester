require 'spec_helper'

describe "practiceobjects/index" do
  before(:each) do
    assign(:practiceobjects, [
      stub_model(Practiceobject,
        :user_id => 1,
        :event_id => 2,
        :first_name => "First Name",
        :last_name => "Last Name",
        :email => "Email",
        :admin_notes => "Admin Notes",
        :userinvite_id => 3,
        :admin_id => 4,
        :token => "Token"
      ),
      stub_model(Practiceobject,
        :user_id => 1,
        :event_id => 2,
        :first_name => "First Name",
        :last_name => "Last Name",
        :email => "Email",
        :admin_notes => "Admin Notes",
        :userinvite_id => 3,
        :admin_id => 4,
        :token => "Token"
      )
    ])
  end

  it "renders a list of practiceobjects" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Admin Notes".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "Token".to_s, :count => 2
  end
end
