class PasswordResetsController < ApplicationController
  def new
  end

  def create
  	  user = User.find_by_email(params[:email])
 	  if user
      user.password_reset_token = SecureRandom.urlsafe_base64
      user.password_reset_sent_at = Time.zone.now
      user.save
 	    UserMailer.password_reset(user, edit_password_reset_url(user.password_reset_token)).deliver
 	    flash[:success] = "Email sent with password reset instructions."
        redirect_to root_url
  	  else
  	  flash.now[:error] = "This email address is not registered on our site."
  	  render 'new'
  	  end 	

  end 


def edit
  @user = User.find_by_password_reset_token!(params[:id])
  #note this different way to use an incoming token - make it the ID of the item in the resource (a 'password reset' instance), like users/5/edit
  # takes user to a url like: password_resets/cS6f9JVIHYVMcRP9Bl_dwg/edit
end

def update
  @user = User.find_by_password_reset_token!(params[:id]) 
  if @user.password_reset_sent_at < 2.hours.ago
    redirect_to new_password_reset_path, :alert => "Password reset has expired."
  elsif @user.update_attributes(params[:user])
    @to = @user.email
    UserMailer.password_change(@user, @to).deliver
  	flash[:success] = "Password has been reset!"
    redirect_to root_url
  else
    render :edit
  end
end

end
