# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
App4::Application.initialize!

#Action Mailer configuration for Heroku

#config.action_mailer.delivery_method = :smtp
# app crashed with the above line, because uninitialized constant config

#ActionMailer::Base.delivery_method = :smtp

#ActionMailer::Base.smtp_settings = {
#  :address  => "smtp.aol.com",
#  :port  => 25,
#  :user_name  => "shanbhagp@aol.com",
 # :password  => "4oceana7ddd",
#  :authentication  => :login
#}

#config.action_mailer.raise_delivery_errors = true