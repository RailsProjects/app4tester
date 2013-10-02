require 'spec_helper'

describe "voicegems/new" do
  before(:each) do
    assign(:voicegem, stub_model(Voicegem,
      :user_id => 1,
      :event_id => 1,
      :first_name => "MyString",
      :last_name => "MyString",
      :email => "MyString",
      :admin_notes => "MyText",
      :vg_userinvite_id => 1,
      :admin_id => 1,
      :token => "MyString",
      :recording => "MyString",
      :request => "MyString",
      :notes => "MyText",
      :hidden => false,
      :length => 1
    ).as_new_record)
  end

  it "renders new voicegem form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => voicegems_path, :method => "post" do
      assert_select "input#voicegem_user_id", :name => "voicegem[user_id]"
      assert_select "input#voicegem_event_id", :name => "voicegem[event_id]"
      assert_select "input#voicegem_first_name", :name => "voicegem[first_name]"
      assert_select "input#voicegem_last_name", :name => "voicegem[last_name]"
      assert_select "input#voicegem_email", :name => "voicegem[email]"
      assert_select "textarea#voicegem_admin_notes", :name => "voicegem[admin_notes]"
      assert_select "input#voicegem_vg_userinvite_id", :name => "voicegem[vg_userinvite_id]"
      assert_select "input#voicegem_admin_id", :name => "voicegem[admin_id]"
      assert_select "input#voicegem_token", :name => "voicegem[token]"
      assert_select "input#voicegem_recording", :name => "voicegem[recording]"
      assert_select "input#voicegem_request", :name => "voicegem[request]"
      assert_select "textarea#voicegem_notes", :name => "voicegem[notes]"
      assert_select "input#voicegem_hidden", :name => "voicegem[hidden]"
      assert_select "input#voicegem_length", :name => "voicegem[length]"
    end
  end
end
