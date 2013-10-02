require 'spec_helper'

describe "emails/index" do
  before(:each) do
    assign(:emails, [
      stub_model(Email,
        :recipient_email => "Recipient Email",
        :from_email => "From Email",
        :body => "MyText",
        :cc_email => "Cc Email"
      ),
      stub_model(Email,
        :recipient_email => "Recipient Email",
        :from_email => "From Email",
        :body => "MyText",
        :cc_email => "Cc Email"
      )
    ])
  end

  it "renders a list of emails" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Recipient Email".to_s, :count => 2
    assert_select "tr>td", :text => "From Email".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Cc Email".to_s, :count => 2
  end
end
