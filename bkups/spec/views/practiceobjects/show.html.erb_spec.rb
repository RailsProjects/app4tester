require 'spec_helper'

describe "practiceobjects/show" do
  before(:each) do
    @practiceobject = assign(:practiceobject, stub_model(Practiceobject,
      :user_id => 1,
      :event_id => 2,
      :first_name => "First Name",
      :last_name => "Last Name",
      :email => "Email",
      :admin_notes => "Admin Notes",
      :userinvite_id => 3,
      :admin_id => 4,
      :token => "Token"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/First Name/)
    rendered.should match(/Last Name/)
    rendered.should match(/Email/)
    rendered.should match(/Admin Notes/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/Token/)
  end
end
