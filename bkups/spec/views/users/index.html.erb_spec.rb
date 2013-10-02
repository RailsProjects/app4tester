require 'spec_helper'

describe "users/index" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :first_name => "First Name",
        :last_name => "Last Name",
        :password_digest => "Password Digest",
        :email => "Email",
        :remember_token => "Remember Token",
        :recording => "Recording",
        :phonetic => "Phonetic",
        :notes => "Notes",
        :admin => false,
        :customer => false
      ),
      stub_model(User,
        :first_name => "First Name",
        :last_name => "Last Name",
        :password_digest => "Password Digest",
        :email => "Email",
        :remember_token => "Remember Token",
        :recording => "Recording",
        :phonetic => "Phonetic",
        :notes => "Notes",
        :admin => false,
        :customer => false
      )
    ])
  end

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Password Digest".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Remember Token".to_s, :count => 2
    assert_select "tr>td", :text => "Recording".to_s, :count => 2
    assert_select "tr>td", :text => "Phonetic".to_s, :count => 2
    assert_select "tr>td", :text => "Notes".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
