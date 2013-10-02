require 'spec_helper'

describe "voicegems/show" do
  before(:each) do
    @voicegem = assign(:voicegem, stub_model(Voicegem,
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
    rendered.should match(/MyText/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/Token/)
    rendered.should match(/Recording/)
    rendered.should match(/Request/)
    rendered.should match(/MyText/)
    rendered.should match(/false/)
    rendered.should match(/5/)
  end
end
