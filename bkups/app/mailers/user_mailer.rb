class UserMailer < ActionMailer::Base
  default from: "no-reply@name-coach.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #


def password_reset(user, url)
  @user = user
  @url = url 
  mail :to => user.email, :subject => "Password Reset"
end

def welcome(user)
  @user = user
  mail :to => user.email, :subject => "Welcome to NameCoach"
end

def vg_welcome(user)
  @user = user
  mail :to => user.email, :subject => "Welcome to VoiceGems (a NameCoach service)"
end

def password_change(user, to)
  @user = user
  mail :to => to, :subject => "Password update for your NameCoach account"
end 

def sub_receipt(user, receipt)

  @user = user
  @r = receipt

  mail :to => user.email, :subject => "NameCoach Subscription Receipt"

end 


def sub_receipt_edu(user, receipt)

  @user = user
  @r = receipt

  mail :to => user.email, :subject => "NameCoach Subscription Receipt"

end 

def purchase_receipt(user, receipt, t1, t2, t3)

  @user = user
  @r = receipt
  @number = @r.events_number

    if @number.to_i < 6 
       @cost = @number.to_i*t1
       @price = "$#{t1}" 
    end 
    if @number.to_i > 5 && @number.to_i < 11 
       @cost = @number.to_i*t2
       @price = "$#{t2}"
    end 
    if @number.to_i > 10 
       @cost = @number.to_i*t3
       @price = "$#{t3}"
    end 

  mail :to => user.email, :subject => "NameCoach Receipt"

end 


def grad_purchase_receipt(user, receipt, cost, price)
# cost in dollars
  @user = user
  @r = receipt
  @number = @r.events_number
  @cost = cost
  @price = "$#{price}"

  mail :to => user.email, :subject => "NameCoach Receipt"

end 

def wed_purchase_receipt(user, receipt, cost, price)
# cost in dollars
  @user = user
  @r = receipt
  @number = @r.events_number
  @cost = cost
  @price = "$#{price}"

  mail :to => user.email, :subject => "NameCoach Receipt"

end 



def testemail(email)
  @email = email
  mail :to => @email.recipient_email, :subject => @email.subject, :from => @email.from_email, :body => @email.body
end 

end
