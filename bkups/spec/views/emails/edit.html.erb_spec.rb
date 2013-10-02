require 'spec_helper'

describe "emails/edit" do
  before(:each) do
    @email = assign(:email, stub_model(Email,
      :recipient_email => "MyString",
      :from_email => "MyString",
      :body => "MyText",
      :cc_email => "MyString"
    ))
  end

  it "renders the edit email form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => emails_path(@email), :method => "post" do
      assert_select "input#email_recipient_email", :name => "email[recipient_email]"
      assert_select "input#email_from_email", :name => "email[from_email]"
      assert_select "textarea#email_body", :name => "email[body]"
      assert_select "input#email_cc_email", :name => "email[cc_email]"
    end
  end
end
