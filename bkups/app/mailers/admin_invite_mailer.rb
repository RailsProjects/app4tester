class AdminInviteMailer < ActionMailer::Base
  default from: "no-reply@name-coach.com"

def admin_invitation(admininvite, url, to)
    @url = url
    @ai = admininvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    mail to: to, subject: "Admin invitation for event: #{@ai.event.title}"
    #mail to: "to@example.org"
   # adminvite.update_attribute(:sent_at, Time.now)
   # need to add at sent_at column to Admininvite model
end


def admin_notify(admininvite, url, to)
    @url = url
    @ai = admininvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    @u = User.find_by_email(@ai.recipient_email)
    mail to: to, subject: "Admin invitation for event: #{@ai.event.title}"
    #mail to: "to@example.org"
   # adminvite.update_attribute(:sent_at, Time.now)
   # need to add at sent_at column to Admininvite model
end

def vg_admin_invitation(admininvite, url, to)
    @url = url
    @ai = admininvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    mail to: to, subject: "Admin invitation for event: #{@ai.event.title}"
    #mail to: "to@example.org"
   # adminvite.update_attribute(:sent_at, Time.now)
   # need to add at sent_at column to Admininvite model
end

def vg_admin_notify(admininvite, url, to)
    @url = url
    @ai = admininvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    @u = User.find_by_email(@ai.recipient_email)
    mail to: to, subject: "Admin invitation for event: #{@ai.event.title}"
    #mail to: "to@example.org"
   # adminvite.update_attribute(:sent_at, Time.now)
   # need to add at sent_at column to Admininvite model
end

end
