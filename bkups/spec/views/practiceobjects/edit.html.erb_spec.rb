require 'spec_helper'

describe "practiceobjects/edit" do
  before(:each) do
    @practiceobject = assign(:practiceobject, stub_model(Practiceobject,
      :user_id => 1,
      :event_id => 1,
      :first_name => "MyString",
      :last_name => "MyString",
      :email => "MyString",
      :admin_notes => "MyString",
      :userinvite_id => 1,
      :admin_id => 1,
      :token => "MyString"
    ))
  end

  it "renders the edit practiceobject form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => practiceobjects_path(@practiceobject), :method => "post" do
      assert_select "input#practiceobject_user_id", :name => "practiceobject[user_id]"
      assert_select "input#practiceobject_event_id", :name => "practiceobject[event_id]"
      assert_select "input#practiceobject_first_name", :name => "practiceobject[first_name]"
      assert_select "input#practiceobject_last_name", :name => "practiceobject[last_name]"
      assert_select "input#practiceobject_email", :name => "practiceobject[email]"
      assert_select "input#practiceobject_admin_notes", :name => "practiceobject[admin_notes]"
      assert_select "input#practiceobject_userinvite_id", :name => "practiceobject[userinvite_id]"
      assert_select "input#practiceobject_admin_id", :name => "practiceobject[admin_id]"
      assert_select "input#practiceobject_token", :name => "practiceobject[token]"
    end
  end
end
