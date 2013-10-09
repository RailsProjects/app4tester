class ApplicationController < ActionController::Base
  protect_from_forgery

  # set up before filter that sets up a session to track which state they are in:
  # whether they are in mobile or full version of site
  before_filter :prepare_for_mobile

  include SessionsHelper
  include UsersHelper
  include EventsHelper
  include SubscriptionsHelper

  private

  def mobile_device?
    if session[:mobile_param]  # if session exists then
      session[:mobile_param] == "1" # then rtn that session if it's == 1 (mobile)
    else
  	  request.user_agent =~ /Mobile|webOS/  #chk user agent string against regex
    end
  end

  helper_method :mobile_device?

  # set mobile_param inside of a session from mobile param if exists
  def prepare_for_mobile
    # set mobile param (passed thru URL) inside of session if it exists
    session[:mobile_param] = params[:mobile] if params[:mobile]
  end
end
