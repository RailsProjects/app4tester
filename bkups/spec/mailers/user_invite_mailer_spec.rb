require "spec_helper"

describe UserInviteMailer do
  describe "user_invitation" do
    let(:mail) { UserInviteMailer.user_invitation }

    it "renders the headers" do
      mail.subject.should eq("User invitation")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
