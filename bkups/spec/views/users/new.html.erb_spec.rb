require 'spec_helper'

describe "users/new" do
  before(:each) do
    assign(:user, stub_model(User,
      :first_name => "MyString",
      :last_name => "MyString",
      :password_digest => "MyString",
      :email => "MyString",
      :remember_token => "MyString",
      :recording => "MyString",
      :phonetic => "MyString",
      :notes => "MyString",
      :admin => false,
      :customer => false
    ).as_new_record)
  end

  it "renders new user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => users_path, :method => "post" do
      assert_select "input#user_first_name", :name => "user[first_name]"
      assert_select "input#user_last_name", :name => "user[last_name]"
      assert_select "input#user_password_digest", :name => "user[password_digest]"
      assert_select "input#user_email", :name => "user[email]"
      assert_select "input#user_remember_token", :name => "user[remember_token]"
      assert_select "input#user_recording", :name => "user[recording]"
      assert_select "input#user_phonetic", :name => "user[phonetic]"
      assert_select "input#user_notes", :name => "user[notes]"
      assert_select "input#user_admin", :name => "user[admin]"
      assert_select "input#user_customer", :name => "user[customer]"
    end
  end
end
