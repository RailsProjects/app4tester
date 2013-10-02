App4::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Change mail delvery to either :smtp, :sendmail, :file, :test
 # config.action_mailer.delivery_method = :letter_opener

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

    # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false
  # added to get account dropdown button to work in development

  # change for production; these configuration settings are working for development!
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "ncwbdev",
  :password             => "bugsbegone101",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

#ActionMailer::Base.default_url_options[:host] = "localhost:3000"
#domain name seemed to be passed in properly into the urls generated in the  email without this line - not sure what's going on
# had to comment this out because was getting a nomethod error for default_url_options once this got moved to env/dev from setupmail

require 'development_mail_interceptor'  #suggestion from stack overflow to get around the iniitialized developmentmailinterceptor problem
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
# comment this out to send email to actual email addresses
#this makes useless lib/tasks/development_mail_interceptor 

config.paperclip_defaults = {
  :storage => :s3,
  :s3_credentials => {
    :bucket => ENV['BUCKET_NAME'],
    :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  }
}

end
