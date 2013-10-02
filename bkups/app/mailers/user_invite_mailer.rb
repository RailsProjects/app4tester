class UserInviteMailer < ActionMailer::Base
  default from: "no-reply@name-coach.com"
  #note that still sends from prshanbhag@gmail.com
  def user_invitation (userinvite, url, po, to)
    @po = po
    @url = url
    @userinvite = userinvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    mail to: to, subject: "Name registration for event: #{@po.event.title}"
    #mail to: "to@example.org"
    userinvite.update_attribute(:sent_at, Time.now)
  end

  def invite_reminder(userinvite, url, po, to)
    @po = po
    @url = url
    @userinvite = userinvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    mail to: to, subject: "Reminder: name registration for event: #{@po.event.title}"
    #mail to: "to@example.org"
    userinvite.update_attributes(:sent_at => Time.now, :invite_type => "registration reminder")
  end

  def recording_reminder(userinvite, url, po, to)
    @po = po
    @url = url
    @userinvite = userinvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    mail to: to, subject: "Please record your name for event: #{@po.event.title}"
    #mail to: "to@example.org"
    userinvite.update_attributes(:sent_at => Time.now, :invite_type => "request to record")
  end

  def rerecording_reminder(userinvite, url, po, to)
    @po = po
    @url = url
    @userinvite = userinvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    mail to: to, subject: "Request to re-record your name for event: #{@po.event.title}"
    #mail to: "to@example.org"
    userinvite.update_attributes(:sent_at => Time.now, :invite_type => "request to re-record")
  end


  def existing_user_invitation (userinvite, url, po, to)
    @po = po
    @url = url
    @userinvite = userinvite 
    @u = User.find_by_email(@po.email)
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    mail to: to, subject: "Name registration for event: #{@po.event.title}"
    #mail to: "to@example.org"
    userinvite.update_attribute(:sent_at, Time.now)
  end

  def vg_rerecording_reminder (vg_userinvite, url, vg, to)
    @vg = vg
    @url = url
    @vg_userinvite = vg_userinvite 
    #subject  "Name registration for event: #{@po.event.title}" 
    #body  :userinvite => userinvite, :url => url, :po => po
    mail to: to, subject: "Please re-record your VoiceGem for event: #{@vg.event.title}"
    #mail to: "to@example.org"
    vg_userinvite.update_attributes(:sent_at => Time.now, :invite_type => "request to re-record")

  end

end
