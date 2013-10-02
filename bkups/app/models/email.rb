class Email < ActiveRecord::Base
  attr_accessible :body, :cc_email, :from_email, :recipient_email, :sent_at, :subject
end
