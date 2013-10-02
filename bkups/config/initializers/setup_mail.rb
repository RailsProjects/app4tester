#ActionMailer::Base.smtp_settings = {
 # :address              => "smtp.gmail.com",
#  :port                 => 587,
#  :domain               => "railscasts.com",
 # :user_name            => "railscasts",
 # :password             => "secret",
 # :authentication       => "plain",
 # :enable_starttls_auto => true
#}

# change for production; these configuration settings are working for development!
# now changed for production
#ActionMailer::Base.smtp_settings = {
#:address => 'smtp.sendgrid.net',
#:port => '587',
#:authentication => :plain,
#:user_name => ENV['SENDGRID_USERNAME'],
#:password => ENV['SENDGRID_PASSWORD'],
#:domain => 'heroku.com'
#}
#ActionMailer::Base.delivery_method = :smtp
#ActionMailer::Base.default_url_options[:host] = "localhost:3000"
#domain name seemed to be passed in properly into the urls generated in the  email without this line - not sure what's going on

#require 'development_mail_interceptor'  #suggestion from stack overflow to get around the iniitialized developmentmailinterceptor problem
#ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development? #commented out for staging interceptor
# comment this out to send email to actual email addresses
#this makes useless lib/tasks/development_mail_interceptor 