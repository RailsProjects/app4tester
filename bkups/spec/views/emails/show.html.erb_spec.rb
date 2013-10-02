require 'spec_helper'

describe "emails/show" do
  before(:each) do
    @email = assign(:email, stub_model(Email,
      :recipient_email => "Recipient Email",
      :from_email => "From Email",
      :body => "MyText",
      :cc_email => "Cc Email"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Recipient Email/)
    rendered.should match(/From Email/)
    rendered.should match(/MyText/)
    rendered.should match(/Cc Email/)
  end
end
