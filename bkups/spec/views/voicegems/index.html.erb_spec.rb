require 'spec_helper'

describe "voicegems/index" do
  before(:each) do
    assign(:voicegems, [
      stub_model(Voicegem,
        :user_id => 1,
        :event_id => 2,
        :first_name => "First Name",
        :last_name => "Last Name",
        :email => "Email",
        :admin_notes => "MyText",
        :vg_userinvite_id => 3,
        :admin_id => 4,
        :token => "Token",
        :recording => "Recording",
        :request => "Request",
        :notes => "MyText",
        :hidden => false,
        :length => 5
      ),
      stub_model(Voicegem,
        :user_id => 1,
        :event_id => 2,
        :first_name => "First Name",
        :last_name => "Last Name",
        :email => "Email",
        :admin_notes => "MyText",
        :vg_userinvite_id => 3,
        :admin_id => 4,
        :token => "Token",
        :recording => "Recording",
        :request => "Request",
        :notes => "MyText",
        :hidden => false,
        :length => 5
      )
    ])
  end

  it "renders a list of voicegems" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "Token".to_s, :count => 2
    assert_select "tr>td", :text => "Recording".to_s, :count => 2
    assert_select "tr>td", :text => "Request".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
  end
end
