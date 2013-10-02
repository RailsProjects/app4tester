require 'spec_helper'

describe "users/show" do
  before(:each) do
    @user = assign(:user, stub_model(User,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/First Name/)
    rendered.should match(/Last Name/)
    rendered.should match(/Password Digest/)
    rendered.should match(/Email/)
    rendered.should match(/Remember Token/)
    rendered.should match(/Recording/)
    rendered.should match(/Phonetic/)
    rendered.should match(/Notes/)
    rendered.should match(/false/)
    rendered.should match(/false/)
  end
end
