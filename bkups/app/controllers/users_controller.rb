class UsersController < ApplicationController
  # GET /users
  # GET /users.json
before_filter :signed_in_user, only: [:index, :skip, :show, :new_step2, :setpassword, :edit, :update, :changepassword, :destroy, 
  :account, :console, :upload, :saveupload, :eventcodesignup_step2, :purchase_sub_existing, :purchase_sub_existing_choose,
  :changesub_existinguser, :sub_coupon_existing_user, :purchase_sub_existing_card, :purchase_sub_new_card,
  :purchase_sub_not_stripe_customer, :stripenewcustomer, :changesub, :sub_coupon, :stripereceiver, :stripenewcustomer_purchase,
  :changepur, :coupon_purchase, :stripereceiver_purchase, :existing_user_purchase, :existing_user_purchase_select,
  :existing_changepur, :existing_coupon_purchase, :purchase_events_existing_card, :purchase_events_new_card, :purchase_events_new_stripe_customer,
  :stripetest]
before_filter :correct_user, only: [:show, :edit, :update, :account, :setpassword]
# before_filter :not_customer, only: [:stripetest] #now allowing for purchasing a sub even if already is a customer
before_filter :customer_has_no_active_subscription, only: [:purchase_sub_existing] #purchase_sub_existing is the path from the 'purchase sub' link
before_filter :owner, only: [:console, :index, :destroy]
# before_filter :set_cache_buster, only: [:show]



  def home
    # check if signed_in and then display (you are currently signed in, view your profile)
    # automatically renders page 'users/home'
     @user = User.new

     @event = Event.find(ENV['demopage'].to_i)

     @practiceobject = Practiceobject.new  
     @practiceobject.event_id = @event.id #for the form_for(@practiceobject) which creatse a new practice object (and another form which just shows the labels - can find a better way for that)
     @registeredandrecordedpos = @event.practiceobjects.registered.recorded.visible
     @registeredandunrecordedpos = @event.practiceobjects.registered.unrecorded.visible
     @unregisteredpos = @event.practiceobjects.unregistered.visible
     @hiddenpos = @event.practiceobjects.hidden
     @hiddenandregisteredpos  = @hiddenpos.registered
     @hiddenandunregisteredpos = @hiddenpos.unregistered  

     @url = demo_record_url(:event_code => @event.event_code)

  end

  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def skip
    if is_haltom_user
      flash[:info] = "Welcome to your NameCoach profile page! You may need to wait a minute and refresh the page to hear your name recording below. Please ensure that your recording plays back, and then signout to allow the next student to record! Thank you!"
      redirect_to current_user
    else 
    flash[:info] = "Welcome to your NameCoach profile page! You may need to wait a minute and refresh the page to hear your name recording below."
    redirect_to current_user
    end 
  end 

  # GET /users/1
  # GET /users/1.json
  def show
    expires_now #because refresh of user show was not giving updated recordings; must have been caching the mp3
    @user = User.find(params[:id])
    #@user.password = BCrypt::Password.new(@user.password_digest)
    #@user.password_confirmation = @user.password
    if @user.phonetic.blank?
      if @user.first_name && @user.last_name
      @user.phonetic = @user.first_name + ' ' + @user.last_name 
      end 
    end  
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
     # if signed_in?
     #  redirect_to root_path  
     # else
      @user = User.new(:invite_token => params[:token])
          if  Practiceobject.find_by_token(@user.invite_token)
                 @po = Practiceobject.find_by_token(@user.invite_token)
                 @user.email = @po.email
                 #this is some polish to automatically set the email field in the form
                 #flash[:notice] = "You have been invited, please sign up and record your name!"
                 #put this back in later when you've figured out the flash/notice thing, included notices inthe application layout
                if @po.first_name
                  @user.first_name = @po.first_name
                end 
                if @po.last_name
                  @user.last_name = @po.last_name
                end 
                @event = @po.event
      #maybe check to see first if there is a token passed in: if params[:token].any? or something; or rather, if
      # the @user already has a :token attribute b/c rendered from a failed create attempt below
      #actually, it seems that users are still being appropriately assoaciated with their practice objects even when they mess up the invited 
      # signup  - I think somehow the token is being passed in here from the failed sign-up as params[:token]? (associated with incoming @user object, which
        #hasn't been reset yet (available to be assigned once more to @user)) no, that seems unlikely since the associated user attribute is
      #invite_token, not token.
      #ANSWER:  we are just re-rendering new, not hitting the new action - none of the new action logic is being executed - @user still has all it's associated
      #fields, including the :invite_token.  
          else 
            redirect_to root_path, notice: 'Invitation invalid or used. If you already signed up, please sign in. If you were following an invite link, please retry the link or contact your event admin.'
             #in case a bad token passed in; but doesn't work for a blank/nil token (when someone just hits users/new without an invite); probably 
                # b/c there are some PO's with nil/blank tokens; also in case user already signed up with that token
          end

   #  end

   end

   def new_step2
      @user = current_user
      @po = Practiceobject.find_by_token(params[:token])
   end 


  def setpassword
    
    @user = User.find(params[:id]) unless params[:id].blank?
    @event = Event.find(params[:event]) unless params[:event].blank?
    @event_code = params[:event_code] unless params[:event_code].blank?
    @vg = params[:vg] unless params[:vg].blank?
    
    if @user.recording.blank? && params[:x].blank?
         flash[:error] = "No recording was uploaded.  Please try again, and make sure to press 'Upload' after you hear your recording play back."
         if bigdaddyevent
          redirect_to vgrecord_step2_path(:user => @user, :vg => @vg, :event => @event, :event_code => @event_code)
         else
         redirect_to record_step2_path
         end 
    else
      flash.now[:info] = "Thank you! You have been given a temporary password. You will need to set a password to access this account in the future."
    end 

  end 

  #UNUSED (I think)  
  # GET /users/1/edit
  def edit
   @user = User.find(params[:id])
   # @user.password = BCrypt::Password.new(@user.password_digest)
   #@user.password_confirmation = @user.password

  end

  # POST /users
  # POST /users.json
  def create  #just for invited with token user signup
    @user = User.new
    @user.email = params[:user][:email]
    @pw = SecureRandom.urlsafe_base64
    @user.invite_token = params[:user][:invite_token]
    @user.password=@pw
    @user.password_confirmation=@pw
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.phonetic = params[:user][:phonetic]
    @user.notes = params[:user][:notes]
    @user.grad_date = params[:user][:grad_date]
    @user.company = params[:user][:company]

    if @user.save  then 
            UserMailer.welcome(@user).deliver
            sign_in @user
            if  Practiceobject.find_by_token(@user.invite_token)  #probably not necessary, just avoiding nomethod errors    
                @po = Practiceobject.find_by_token(@user.invite_token) #note that don't need to check if there's a PO for this event w/ this users's email, because this is only a problem if an invited attendee signs up with an email address for another attendee (and this would show up under the email field)
                @po.user_id = @user.id                                #plus, we want this user to be stuck with the PO that was sent to his inbox anyway, so if he signs in with the em address for another invited attendee, that will only affect his PO and show that he was invited at a different em address but using this other one.
                                                                      # plus, we can cover this sort of chicanery by sending a confirmation email whenever a new user signs up. 
                @po.notes = @user.notes
                @po.phonetic = @user.phonetic
                @po.token = "used"
                if @po.save #just to be sure, wrapping this in an if-else-end.  Would fail only if somehow user already had a PO for this event (which couldn't happen because signing up with same email is already not allowed)
                  flash[:info] = "Now just record your name, and you're done!"

                  redirect_to new_step2_path(:token => @po.token)
                else
                  redirect_to new_step2_path(:token => @po.token)
                end 
                 anchor_and_update_pos(@po)
                 copy_to_master(@po, @po.event)  #for copying the new PO to the master list if the @event here is a sublist.
            
            else #couldn't find practice object by token
                  redirect_to new_step2_path(:token => @po.token), notice: 'There was an error.  Please sign out and try again.'
            end 

            
    else  
          if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right; won't save becaues @user represents a User.new record here
              flash.now[:error] = "You have previously registered on our site. Please follow the link below ('Already Registered on our Site?') and sign in.  Click 'Reset Password' above if you haven't set a password yet." 
          end 
          if  Practiceobject.find_by_token(@user.invite_token)
                 @po = Practiceobject.find_by_token(@user.invite_token)
                 if @user.email.blank?
                    @user.email = @po.email
                 end 
          end # to re-render personalized invite info
          
            render action: 'new'  #this is causing a problem: render 'new' wont' work bc the view requires the controller to set @po, but when coming from the 
                                      # home page, we bypass setting @po.  I think this is fixed now.
                              # failed save attempt from 'new' form without an invite creates a problem b/c @po not set.  fixed by redirect to root path in 'new' action 
    end
    #respond_to do |format|
     # if @user.save
      #  sign_in @user
      #  format.html { redirect_to edit_user_path(@user), notice: 'Welcome to Namewaves.' }
        # format.json { render json: @user, status: :created, location: @user }
     # else
      #  format.html { render action: "new" }
        #format.json { render json: @user.errors, status: :unprocessable_entity }
    #  end
    #end
end


#think this is no longer being used.
  def homepageusercreate
    @user = User.new
    @user.email = params[:user][:email]
    @user.password=params[:user][:password]
    @user.password_confirmation=params[:user][:password_confirmation] 

    if @user.save  
        sign_in @user     
        redirect_to @user, notice: 'Welcome to NameCoach! From here, you can edit your NameGuide, or sign up for a free trial to use our NameCoach service.'
    else
        render action: 'home'  #this is causing a problem: render 'new' wont' work bc the view requires the controller to set @po, but when coming from the 
                                      # home page, we bypass setting @po.
    end
  end 

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
  
  
      if @user.update_attributes(params[:user])  

            if @user.practiceobjects.count == 1  #this should fix the problem from below- we're only dealing with situations in which the user has 1 PO
              @user.practiceobjects.each do |p|  # this makes any changes to user notes/name as announced default changes for any blank parallel fields in the users PO's.  
                                                # mainly to update the practiceobject when the user first fills out that info
                  
                  # this SHOULD only update the PO when the user has only one PO, because won't have access to the form that hits this action if he has more than one PO
                  #NEED TO MAKE SURE OF THIS - MAKE SURE THIS ACTION NOT HIT FROM ANYWHERE ELSE, not hit any other time the PO is updated - IS IT HIT WHEN ADMIN NOTES UPDATED THROUGH BEST IN PLACE?
                    # after looking at the terminal output, it doesn't look like best_in_place hits this update action, so it's cool
                    #THIS WON"T WORK - ANY update to the user, e.g. when updating password, will change all PO values back to the default - see fix above
                    p.update_attributes(:notes => @user.notes)
                  
                  
                    p.update_attributes(:phonetic => @user.phonetic)
                end 
            end 

          if params[:user][:password]  #I think this only occurs when user sets pw for the first time, when signing up.
                 
                    if is_haltom_user
                      flash[:info] = "Welcome to your NameCoach profile page! You may need to wait a minute and refresh the page to hear your name recording below. Please ensure that your recording plays back, and then signout to allow the next student to record! Thank you!"
                      redirect_to @user
                    else 
                       flash[:info] = "Welcome to your NameCoach profile page! You may need to wait a minute and refresh the page to hear your recording below."
                       redirect_to @user
                    end
          else
            if params[:user][:email]
              redirect_to @user, notice: 'User update was successful.'
            else 
             redirect_to @user, notice: 'Update was successful.  If you uploaded a recording, please wait a minute and refresh the page to see the changes take effect.' 
            end 
          end       
          
     
      else
          if params[:user][:password]
              render action: "setpassword" 
          else
                  if params[:user][:email]
                    render action: "edit"
                  else
                  flash[:error] = "Something went wrong, please try again."
                   redirect_to current_user
                  end 
          end
        #format.html { render action: "edit" } redirect_to(session[:return_to] || edit_user_path)
       # format.html { redirect_to (session[:return_to] || edit_user_path(@user))} 
        #format.json { render json: @user.errors, status: :unprocessable_entity }
      end
  
  end

  #for changing password once you've signed in
  def changepassword
    @user = current_user
    if @user.update_attributes(params[:user]) then 
         UserMailer.password_change(@user, @user.email).deliver 
         redirect_to @user, notice: 'Password update was successful.' 
    else
        render action: "account"
    end 
  end 

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

def account
   @user = User.find(params[:id])
   #store_location
end
# this is not giving the proper error messages because redirecting rather than rendering in the update action
# can either try to render instead of redirect, or 
#this is working now!
# don't remember why i have store_location in here - I think i take care of the proper redirects/renders in the update action, so no need

#def post_account
# @user = User.find(params[:id])

#    respond_to do |format|
 #    if @user.update_attributes(params[:user])
 #       format.html { redirect_to @user, notice: 'User was successfully updated.' }
 #       format.json { head :no_content }
 #     else
 #       format.html { render action: "account" }
 #     format.json { render json: @user.errors, status: :unprocessable_entity }
 #    end
 #   end
#end

def invitedsignup
  redirect_to root_path
end
#don't think this is being  used


def console
end

# NOT BEING USED (I think)
def saverecording
 @user = current_user
 @user.update_attributes(recording: @user.id)
if Practiceobject.find_by_user_id(@user.id)
   @po = Practiceobject.find_by_user_id(@user.id)
   #need to make sure this updates the CURRENT practice object (not just the first one found)!  In general, allow user to update the PO recording rather than 
   #the user recording when he has multiple po's 
   @po.update_attributes(recording: @user.recording)
end 
 redirect_to @user, notice: 'Recording saved'
end


def test

  @user = User.find(params[:id])
  render :layout => nil
  # necessary b/c having the rendered header was causing problems on the test page
end 


def autotest

  @user = User.find(params[:id])
  render :layout => nil
  # necessary b/c having the rendered header was causing problems on the test page
end 


# NOT BEING USED (I think)
def upload
       @user = current_user
 @user.update_attributes(recording: @user.id)
if Practiceobject.find_by_user_id(@user.id)
   @po = Practiceobject.find_by_user_id(@user.id)
   #need to make sure this updates the CURRENT practice object (not just the first one found)!  In general, allow user to update the PO recording rather than 
   #the user recording when he has multiple po's 
   @po.update_attributes(recording: @user.recording)
end 
 redirect_to test_user_path(current_user), notice: 'Recording uploaded'

end


def saveupload

      directory = "app/assets/images"
      # create the file path
      path = File.join(directory, current_user.id.to_s)
      path+='.wav'
     # write the file to local images directory
      File.open(path, "wb") { |f| f.write(request.body.read) }

      #upload to S3
       bucket_name = ENV['BUCKET_NAME']
       source_filename = path 

        AWS.config(
          :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
        )

        # Create the basic S3 object
        s3 = AWS::S3.new

        # Load up the 'bucket' we want to store things in
        bucket = s3.buckets[bucket_name]

        # If the bucket doesn't exist, create it
        unless bucket.exists?
          puts "Need to make bucket #{bucket_name}.."
          s3.buckets.create(bucket_name)
        end

        # Grab a reference to an object in the bucket with the name we require
        object = bucket.objects[File.basename(source_filename)]

        # Write a local file to the aforementioned object on S3
        object.write(:file => source_filename)
       
        #transcode the file as a genuine mp3 via Zencoder
        Zencoder::Job.create({
                      :api_key => ENV['ZEN_API_KEY'],    
                      :input => "s3://#{ENV['BUCKET_NAME']}/#{current_user.id.to_s}.wav",
                      :outputs => [
                        {
                          :url => "s3://#{ENV['BUCKET_NAME']}/#{current_user.id.to_s}.mp3",
                          :audio_codec => "mp3",
                          :public => 1,

                          }]

                          })



        #update the recording path for the current user and the (first?) practice object; this is coped from the upload action, and 
        # cleans up the code by using current_user
        #this should really only happen for the users first(only) practiceobject, as after that they are forced to edit a PO through the PO update action.
        #important to have it here so that as soon as the user first records, his PO's recording path gets a value
        current_user.update_attributes(recording: current_user.id)
          if current_user.practiceobjects.any? 
             current_user.practiceobjects.each do |x|
               if x.recording.blank?
               x.update_attributes(recording: current_user.recording)
               end 
             end    
          end 

      false 

  end



def eventcodesignup
    @user = User.new
end 

# for event code url signup
#def signup
#  @user = User.new 
#end 

def eventcodesignup_step2
   @user = current_user
end 

def eventcodesignupcreate  #for new users signing up with an event code
    @user = User.new
    @user.email = params[:user][:email]
    @pw = SecureRandom.urlsafe_base64
    @user.password=@pw
    @user.password_confirmation=@pw
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.phonetic = params[:user][:phonetic]
    @user.notes = params[:user][:notes]
    @user.event_code = params[:user][:event_code]
          #moved this up here so that what user entered is left in tact when re-renders form, and can take out @user = User.new below 

if !params[:user][:event_code].blank? #see if any code parameter is passed incoming from the form - don't want to run this code if not, i.e., if user is signing up                from an inviation token
    if Event.find_by_event_code(params[:user][:event_code].upcase.delete(' ')) # see if the code entered is even a code for any event - params[:code] is coming in from the form
                          #but how to get code in from the form?    
      @event  = Event.find_by_event_code(params[:user][:event_code].upcase.delete(' '))
      #run code to sign up user for this event, first to try to save the user (validate his info)
      
            if @user.save
                UserMailer.welcome(@user).deliver
                sign_in @user
                # try to give user a PO for this event
                  # first check to see if an existing PO with this email for this event, and leave the other events/PO's alone; if floating  # PO's with this email for other events, will be caught by the sign-up level checks - user can just sign in then to anchor 
                  # themselves to that PO/event
                  if !@event.practiceobjects.nil? && @event.practiceobjects.find_by_email(@user.email)  #there is an already a PO with user's em for this event, floating
                      @po = @event.practiceobjects.find_by_email(@user.email)
                      @po.update_attributes(:user_id => @user.id, :phonetic => @user.phonetic, :notes => @user.notes) #this should validate b/c # user is new 
                      flash[:info] = "Now just record your name for this event (#{@event.title}), and you're done!"
                      redirect_to eventcodesignup_step2_path
                  else #no floating PO's associated with this email for this event (from an 'invite attendee' invitation), so give a new PO
                        @po = Practiceobject.new(:user_id => @user.id, :event_id => @event.id, :email => @user.email, :first_name => @user.first_name, :last_name => @user.last_name, :phonetic => @user.phonetic, :notes => @user.notes) #needed to add email to PO to make sure PO saves, b/c of PO validations}
                        if @po.save  #should be fine - since this is a new user, there can't be a PO for this event with his ID - true, but            #still problem if ADMIN ALSO INVITED AT THAT EMAIL ADDRESS, THEREBY CREATING A PO, AND USER HASN'T            #REGISTERED YET
                           flash[:info] = "Now just record your name for this event (#{@event.title}), and you're done!"
                           redirect_to eventcodesignup_step2_path
                        else #already a PO for this user_id and event, but this shouldn't happen since it's a new user
                          redirect_to @user, notice: "Thanks for registering. However, something may have gone wrong - please contact your event admin for #{@event.title} to see if they can view your NameGuide/recording. If they can't, please ask them to send you an email invitation to a different email."
                        end 
                  end 

                anchor_and_update_pos(@po)    

            else # user already exists, or otherwise didn't validate as user
                  #redirect back to this sign-up form - should render errors; if it's because ther user already exists, this is covered by the 
                  # sign-in form on form, but maybe good to check first and tell user to sign-in.  Notice: "If you have already registered, please sign in under 'Already Registered.'""
                    if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
                            flash[:error] = "You have previously registered on our site. Please sign in under 'Already Registered?' (below) to register for another event."
                             redirect_to eventcodesignup_path
                    else
                      render action: 'eventcodesignup'
                    end     
                    
            end   
    else #code entered doesn't exist for any event
      #@user = User.new #for the re-rendering of the eventcodesignup view
      #render this action again, with the flash message
      flash.now[:error] = 'The event code is not a valid code for any event.'
      render action: 'eventcodesignup'
    end 
else
  #@user = User.new #for the re-redering of the eventcodesignup view
  #run existing users#create code - maybe make this a helper method
  # or make this whole code a separate controller action, and just redirect to the form saying no code was entered
  flash.now[:error] = 'Please enter an event code.  You should have received this from the person inviting you to record your name for the event.'
  render action: 'eventcodesignup'
  
  
end

end


def admincodesignup
  @user = User.new 
end


def admincodesignupcreate #for new users signing up to admin with a code

          @user = User.new
          @user.email = params[:user][:email]
          @user.password=params[:user][:password]
          @user.password_confirmation=params[:user][:password_confirmation]
          @user.first_name = params[:user][:first_name]
          @user.last_name = params[:user][:last_name]
          @user.access_code = params[:user][:access_code]
          #moved this up here so that what user entered is left in tact when re-renders form, and can take out @user = User.new below 

if !params[:user][:access_code].blank? #see if any code parameter is passed incoming from the form - don't want to run this code if not, i.e., if user is signing up                from an inviation token
    if Event.find_by_access_code(params[:user][:access_code].upcase.delete(' ')) # see if the code entered is even an access(admin) code for any event - params[:code] is coming in from the form
                          #but how to get code in from the form?    
      @event  = Event.find_by_access_code(params[:user][:access_code].upcase.delete(' '))
      #run code to sign up user for this event, first to try to save the user (validate his info)
      @user.admin = true
            if @user.save
                sign_in @user
                #create adminkey for this event/user_id - should work b/c the user is brand new, so don't worry about wrapping save in an if statement
                @adminkey = Adminkey.new(event_id: @event.id, user_id: @user.id)
                @adminkey.save 
                make_master_admin(@event, @user)
                # try to give user a PO for this event
                  # first check to see if an existing PO with this email for this event, and leave the other events/PO's alone; if floating  # PO's with this email for other events, will be caught by the sign-up level checks - user can just sign in then to anchor 
                  # themselves to that PO/event
                  if !@event.practiceobjects.nil? && @event.practiceobjects.find_by_email(@user.email)  #there is an already a PO with user's em for this event, floating
                      @po = @event.practiceobjects.find_by_email(@user.email)
                      @po.update_attributes(:user_id => @user.id) #this should validate b/c # user is new 
                      redirect_to @user, notice: "Welcome to NameCoach, and thanks for registering to admin this event, #{@event.title}. Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
                  else #no floating PO's associated with this email for this event (from an 'invite attendee' invitation), so give a new PO
                        @po = Practiceobject.new(:user_id => @user.id, :event_id => @event.id, :email => @user.email, :first_name => @user.first_name, :last_name => @user.last_name) #needed to add email to PO to make sure PO saves, b/c of PO validations}
                        if @po.save  #should be fine - since this is a new user, there can't be a PO for this event with his ID - true, but            #still problem if ADMIN ALSO INVITED AT THAT EMAIL ADDRESS, THEREBY CREATING A PO, AND USER HASN'T            #REGISTERED YET
                          redirect_to @user, notice: "Welcome to NameCoach, and thanks for registering to admin this event, #{@event.title}.  Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
                        else #already a PO for this user_id and event, but this shouldn't happen since it's a new user
                          redirect_to @user, notice: "Thanks for registering as an admin for this event. However, something may have gone wrong - please contact your event admin for #{@event.title}."
                        end 
                  end 
                  anchor_and_update_pos(@po) 
                    
            else # user already exists, or otherwise didn't validate as user
                  #redirect back to this sign-up form - should render errors; if it's because ther user already exists, this is covered by the 
                  # sign-in form on form, but maybe good to check first and tell user to sign-in.  Notice: "If you have already registered, please sign in under 'Already Registered.'""
                    if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
                            flash[:error] = "You have previously registered on our site. Please sign in under 'Already Registered?' to register as an admin for another event."
                             redirect_to admincodesignup_path
                    else
                      render action: 'admincodesignup'
                    end     
                    
            end   
    else #code entered doesn't exist for any event
      #@user = User.new #for the re-rendering of the eventcodesignup view
      #render this action again, with the flash message
      flash.now[:error] = 'The admin code is not a valid code for any event.'
      render action: 'admincodesignup'
    end 
else
  #@user = User.new #for the re-redering of the eventcodesignup view
  #run existing users#create code - maybe make this a helper method
  # or make this whole code a separate controller action, and just redirect to the form saying no code was entered
  flash.now[:error] = 'Please enter an admin code.'
  render action: 'admincodesignup'
  
  
end



end #admincodesignupcreate


# for an existing user w/ no active sub (either never a customer, or canceled a sub, or just bought events) to purchase a subscription
def purchase_sub_existing
  @first_plan = Plan.find_by_my_plan_id(plan_set_one) # sets @first_plan the first plan object ACCORDING TO MY LEGEND (with my_plan_id)
  @second_plan = Plan.find_by_my_plan_id(plan_set_two)
  @third_plan = Plan.find_by_my_plan_id(plan_set_three)
end 

#-------------------- Education Existing User Purchase -------------------------------------------------------------------------
def purchase_sub_existing_edu #much copied from static#students , but much not needed  #in case use customer registers but then comes back later to finish purchasing
      @event = Event.find(ENV['demopage'].to_i)
      @commencement_plan = Plan.find_by_my_plan_id(plan_set_commencement) # sets @first_plan the first plan object ACCORDING TO MY LEGEND (with my_plan_id)
      @students_plan = Plan.find_by_my_plan_id(plan_set_students)
      @all_inclusive_plan = Plan.find_by_my_plan_id(plan_set_all_inclusive)
      @practiceobject = Practiceobject.new  
      @practiceobject.event_id = @event.id #for the form_for(@practiceobject) which creatse a new practice object (and another form which just shows the labels - can find a better way for that)
      @registeredandrecordedpos = @event.practiceobjects.registered.recorded.visible
      @registeredandunrecordedpos = @event.practiceobjects.registered.unrecorded.visible
      @unregisteredpos = @event.practiceobjects.unregistered.visible
      @hiddenpos = @event.practiceobjects.hidden
      @hiddenandregisteredpos  = @hiddenpos.registered
      @hiddenandunregisteredpos = @hiddenpos.unregistered  

      @url = demo_record_directory_url(:event_code => @event.event_code)
end 

#incoming from purchase_sub_existing_edu view
def purchase_sub_existing_edu_bridge #like newcustomer action  #channeling back to original checkout process
  @user = current_user
  @plan = params[:snc][:plan] #gives my_plan_id
  @event_type = params[:snc][:event_type] #gives 'reception' or 'wedding' depending on the channel; actually, will just be 'reception', since wedding channel has it's own controller
  
  #re-set customer event type
  @user.update_attributes(:event_type => @event_type)

  if signed_in?
    if customer_has_active_subscription?
    flash[:success] = "You have already subscribed to our service. If you wish to change your subscription, please contact us.  Thank you!."
    redirect_to current_user
    else 
     #flash[:notice] = "Since you are already a registered user, please use this page to purchase a subscription."
     @planobject = Plan.find_by_my_plan_id(@plan)
     @events_number = @planobject.events_number 
     @user = current_user
     render 'stripenewcustomer_edu'
    end 
  end

end 

#-------------------- Education Existing User Purchase Code Ends -------------------------------------------------------------------------

#renders checkout page for existing users w/o active sub buying a subscription
def purchase_sub_existing_choose
  @plan = params[:sec][:plan] #now this is an integer, my_plan_id
  @planobject = Plan.find_by_my_plan_id(@plan)
  @events_number = @planobject.events_number 
  # if user is a stripe customer (even though no acticve sub), want to allow him to use existing card
   if !current_user.customer_id.blank?  
     c = Stripe::Customer.retrieve(current_user.customer_id)
     @last4 = c.active_card.last4
     @cardtype = c.active_card.type
   end 

end 

#for changing subscription choice on existing user purchase subscription checkout
def changesub_existinguser
   @plan = params[:sub][:plan]  # this is an integer corresponding to my_plan_id
   @planobject = Plan.find_by_my_plan_id(@plan)
   @events_number = @planobject.events_number 
   @code = params[:sub][:code]

    if is_valid_sub_coupon(@code) && !@planobject.nil?
          @coupon = Coupon.find_by_name(@code)
          @new_price = @planobject.monthly_cost_cents * (100 - @coupon.percent_off)/100
          flash.now[:success] = "Your promo code has been applied!"
    else #could not find that coupon
      @code = nil 
      @coupon = nil 
      @new_price = nil
    end

   if !current_user.customer_id.blank?
     c = Stripe::Customer.retrieve(current_user.customer_id)
     @last4 = c.active_card.last4
     @cardtype = c.active_card.type
   end 

   render action: 'purchase_sub_existing_choose'

end 

def sub_coupon_existing_user
  @plan = params[:sub][:plan]  #this is an integer, corresponding to my_plan_id
  @planobject = Plan.find_by_my_plan_id(@plan)
  @events_number = @planobject.events_number
  @code = params[:sub][:code]

   if !current_user.customer_id.blank?
     c = Stripe::Customer.retrieve(current_user.customer_id)
     @last4 = c.active_card.last4
     @cardtype = c.active_card.type
   end 

  if is_valid_sub_coupon(@code) && !@planobject.nil? && has_not_trialed?  # to stop people from getting a code and applying it (by cancelling then resubscribing) when already been subscribed for a while
          @coupon = Coupon.find_by_name(@code)
          @new_price = @planobject.monthly_cost_cents * (100 - @coupon.percent_off)/100
          flash.now[:success] = "Your promo code has been applied!"
          render action: 'purchase_sub_existing_choose'
      
    else #could not find that coupon
      @code = nil 
      @coupon = nil 
      @new_price = nil
      flash.now[:error] = "Sorry, not a valid promo code."
      render action: 'purchase_sub_existing_choose'
    end


end

# charge stripe and create sub for existing user with no active sub purchasing a sub with existing cc details
def purchase_sub_existing_card
  @plan = params[:sub][:plan]   #integer corresponding to my_plan_id
  @events_number = params[:sub][:events_number]
  @code = params[:sub][:code]
  @new_price = params[:sub][:new_price]

  # retrieve stripe customer object yet again
  if !current_user.customer_id.blank?
     c = Stripe::Customer.retrieve(current_user.customer_id)
  end 
  
  if is_valid_sub_coupon(@code) 

       #create subscription for this customer in stripe (note that update_subscription creates a new subscription for this customer in this case)
      if has_not_trialed?
          c.update_subscription(:plan => @plan, :coupon => @code)
      else
          c.update_subscription(:plan => @plan, :trial_end => (Date.today + 1.day).to_time.to_i, :coupon => @code) 
      end 
      #create new subscription object in my database
      @sub = Subscription.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id, :my_plan_id => @plan, :plan_name => Plan.find_by_my_plan_id(@plan).name, :active => true)
      @sub.events_remaining = @events_number
      @sub.coupon = @code
      @sub.save 

       #create receipt
      @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id,
        :subscription_id => @sub.id, :sub_my_plan_id => @sub.my_plan_id, :sub_plan_name => @sub.plan_name,
        :sub_events_number => @sub.events_remaining, :sub_reg_monthly_cost_in_cents => Plan.find_by_my_plan_id(@sub.my_plan_id).monthly_cost_cents,
        :sub_actual_monthly_cost_in_cents => @new_price, :sub_coupon_name => @sub.coupon) 
      @r.save

      #mail receipt
      UserMailer.sub_receipt(current_user, @r).deliver

  else
      #create subscription for this customer in stripe (note that update_subscription creates a new subscription for this customer in this case)
      if has_not_trialed?
          c.update_subscription(:plan => @plan)
      else
          c.update_subscription(:plan => @plan, :trial_end => (Date.today + 1.day).to_time.to_i) 
      end 
          #create new subscription object in my database
      @sub = Subscription.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id, :my_plan_id => @plan, :plan_name => Plan.find_by_my_plan_id(@plan).name, :active => true)
      @sub.events_remaining = @events_number
      @sub.save 

       #create receipt
      @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id,
        :subscription_id => @sub.id, :sub_my_plan_id => @sub.my_plan_id, :sub_plan_name => @sub.plan_name,
        :sub_events_number => @sub.events_remaining, :sub_reg_monthly_cost_in_cents => Plan.find_by_my_plan_id(@sub.my_plan_id).monthly_cost_cents,
        :sub_actual_monthly_cost_in_cents => @new_price, :sub_coupon_name => @sub.coupon) 
      @r.save

      #mail receipt
      UserMailer.sub_receipt(current_user, @r).deliver
  end 


  flash[:success] = "Thank you! You are now subscribed to the #{Plan.find_by_my_plan_id(@plan).name.titleize} plan!"
  redirect_to current_user

  #rescue Stripe::StripeError => e  # THIS CODE WORKS!!!  NEEED TO FIGURE OUT HOW EXACTLY
  #       logger.error "Stripe error while creating subscription w/o active sub for existing user with card on file (purchase_sub_existing_card)"
  #       flash[:error] = "Something went wrong.  Please try again or contact us!"
   #      redirect_to current_user

end 

# stripe receiver for new cc details when creating sub for existing user with no active sub purchasing a sub, when already a stripe customer 
def purchase_sub_new_card
  token = params[:stripeToken]
  @plan = params[:plan] #integer corresponding to my_plan_id
  @events_number = params[:events_number] 
  @code = params[:code]
  @new_price = params[:new_price]

  if update_card_and_new_subscription(token, @plan, @code)
    c = Stripe::Customer.retrieve(current_user.customer_id)
 
    #create new subscription object in my database
    @sub = Subscription.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id, :my_plan_id => @plan, :plan_name => Plan.find_by_my_plan_id(@plan).name, :active => true)
    @sub.events_remaining = @events_number
    @sub.coupon = @code 
    @sub.save 

      #create receipt
      @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id,
        :subscription_id => @sub.id, :sub_my_plan_id => @sub.my_plan_id, :sub_plan_name => @sub.plan_name,
        :sub_events_number => @sub.events_remaining, :sub_reg_monthly_cost_in_cents => Plan.find_by_my_plan_id(@sub.my_plan_id).monthly_cost_cents,
        :sub_actual_monthly_cost_in_cents => @new_price, :sub_coupon_name => @sub.coupon) 
      @r.save

      #mail receipt
      UserMailer.sub_receipt(current_user, @r).deliver

    flash[:success] = "Thank you for subscribing to the #{Plan.find_by_my_plan_id(@plan).name.titleize} plan!"
    redirect_to current_user

  else
    redirect_to purchase_sub_existing_path
  end 


end 

# stripe receiver for new cc details when creating sub for existing user with no active sub purchasing a sub, when NOT already a stripe customer
def purchase_sub_not_stripe_customer
  token = params[:stripeToken]
  @plan = params[:plan] #integer corresponding to my_plan_id
  @events_number = params[:events_number]  #not being used right now because create_customer helper finds the events_number form the plan object via @plan argument
  @code = params[:code] 
  @new_price = params[:new_price]

   if create_customer(token, @plan, @code, @new_price)  #using the same helper as when a new user signs up as a customer
              #record stripe's (?) customer_id for this user
              # this helper is in users helper
          
          redirect_to current_user
   else
            @first_plan = Plan.find_by_my_plan_id(plan_set_one) # sets @first_plan the first plan object ACCORDING TO MY LEGEND (with my_plan_id)
            @second_plan = Plan.find_by_my_plan_id(plan_set_two)
            @third_plan = Plan.find_by_my_plan_id(plan_set_three)
            #These above are required to properly render purchase_sub_existing. Not changing below to redirect because the create_customer helper is creating Flash.nows, not Flashs, and this helper also being used in for totally new customers/users
          render 'purchase_sub_existing'
   end 


end 




def newcustomer
  @user = User.new 
  @plan = params[:snc][:plan] #gives my_plan_id
  @event_type = params[:snc][:event_type] #gives 'reception' or 'wedding' depending on the channel; actually, will just be 'reception', since wedding channel has it's own controller

  if signed_in?
    if customer_has_active_subscription?
    flash[:success] = "You have already subscribed to our service. If you wish to change your subscription, please contact us.  Thank you!."
    redirect_to current_user
    else 
    flash[:notice] = "Since you are already a registered user, please use this page to purchase a subscription."
     @planobject = Plan.find_by_my_plan_id(@plan)
     @events_number = @planobject.events_number 
     @user = current_user
    render 'stripenewcustomer_edu'
    end 
  end
end 

def newcustomercreate
  
    @user = User.new
    @user.email = params[:user][:email]
    @user.password=params[:user][:password]
    @user.password_confirmation=params[:user][:password_confirmation]
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.event_type = params[:user][:event_type]
    @plan = params[:user][:plan]  #this will pass in the @plan value (my_plan_id) into the stripenewcustomer page via the render 'stripenewcustomer' below (changed this from redirect, wasn't sure that would work)
    @planobject = Plan.find_by_my_plan_id(@plan)
    @events_number = @planobject.events_number 
    @event_type = params[:user][:event_type]  #in case user does not save, need this passed back into the newcustomer form

    if @user.save

      sign_in @user
      # since user is new, won't have any PO with user_id; might have floating PO's with this email for some event, but those would be caught later when customer signs in for those events
      # when creates an event, can invite himself (at that email) to create a PO for that event for himself
      flash[:success] = "Thank you for registering.  Please fill in your payment details to finish subscribing."
      if @user.email == 'shanbhagp@aol.com'
          @user.customer = true
          @user.save
      end 
      if @user.email == 'startx@example.com'
          @user.customer = true
          @user.save
      end 
      if @user.email == 'teststartx@example.com'
          @user.customer = true
          @user.save
      end 
        if @user.event_type == 'reception'
          render 'stripenewcustomer'
        else #users(customer's) event type is an edu type
          render 'stripenewcustomer_edu'
        end

    else

          if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
                        flash[:error] = "You are already registered on our site. Please sign in, and go to 'Purchase Subscription' under your Account tab."
                         redirect_to root_path
          else
              render action: 'newcustomer'
          end    

    end 

end 


def stripenewcustomer 
  #@plan = 'silver'  #just in case for some reason @plan is not defined in the view, will have default value of 'basic'.  Note that if there are card processing errors, for some reason the @plan value is not retained in the view
  @coupon = nil #default when form first renders.  Won't be set by this line in the subsequent renderings of stripenewcustomer below
  @code = nil 
end 

def stripenewcustomer_edu 
  #@plan = 'silver'  #just in case for some reason @plan is not defined in the view, will have default value of 'basic'.  Note that if there are card processing errors, for some reason the @plan value is not retained in the view
  @coupon = nil #default when form first renders.  Won't be set by this line in the subsequent renderings of stripenewcustomer below
  @code = nil 
end 


#def hide
#  redirect_to root_path
#end 
#just for testing (deleting PO's) - not real code

#just for testing the layout of the stripnewcustomer page
def stripenewcustomertesting
end

#for changing subscription order on new customer checkout
def changesub
  @plan = params[:sub][:plan]
  @planobject = Plan.find_by_my_plan_id(@plan)
  @events_number = @planobject.events_number 
  @code = params[:sub][:code]

    # don't need to check the is_valid_free_sub, because customer is auto-created if that helper is successful in sub_coupon
    if is_valid_sub_coupon(@code) && !@planobject.nil?
          @coupon = Coupon.find_by_free_page_name(@code)
          @new_price = @planobject.monthly_cost_cents * (100 - @coupon.percent_off)/100
          flash.now[:success] = "Your promo code has been applied!"
    else #could not find that coupon
      @code = nil 
      @coupon = nil 
      @new_price = nil
    end
  render action: 'stripenewcustomer'
end 

#addding event_type to plans so changes the user's event_type in this action
def changesub_edu
  @plan = params[:sub][:plan]
  @planobject = Plan.find_by_my_plan_id(@plan)
  @events_number = @planobject.events_number 
  @code = params[:sub][:code]
  current_user.update_attributes(:event_type => @planobject.event_type)


    # don't need to check the is_valid_free_sub, because customer is auto-created if that helper is successful in sub_coupon
    if is_valid_sub_coupon(@code) && !@planobject.nil?
          @coupon = Coupon.find_by_free_page_name(@code)
          @new_price = @planobject.annual_cost_cents * (100 - @coupon.percent_off)/100
          flash.now[:success] = "Your promo code has been applied!"
    else #could not find that coupon
      @code = nil 
      @coupon = nil 
      @new_price = nil
    end
  render action: 'stripenewcustomer_edu'
end 

def sub_coupon 
  @plan = params[:coup][:plan]
  @planobject = Plan.find_by_my_plan_id(@plan)
  @events_number = @planobject.events_number
  @code = params[:coup][:code]
  
   if is_valid_free_sub(@code) && !@planobject.nil?
          create_sub_customer_without_stripe(@plan, @code)
          flash[:success] = "Thank you for using NameCoach! (No payment details were needed, and you have not been charged.) You can now create an event page, from which you can 1) invite attendees to record their names, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
          redirect_to current_user
   elsif is_valid_sub_coupon(@code) && !@planobject.nil? 
          @coupon = Coupon.find_by_free_page_name(@code)
          @new_price = @planobject.monthly_cost_cents * (100 - @coupon.percent_off)/100
          flash.now[:success] = "Your promo code has been applied!"
          render action: 'stripenewcustomer'

    else #could not find that coupon
      @code = nil 
      @coupon = nil 
      @new_price = nil
      flash.now[:error] = "Sorry, not a valid promo code."
      render action: 'stripenewcustomer'
    end
end 

def sub_coupon_edu
  @plan = params[:coup][:plan]
  @planobject = Plan.find_by_my_plan_id(@plan)
  @events_number = @planobject.events_number
  @code = params[:coup][:code]
  
   if is_valid_free_sub(@code) && !@planobject.nil?
          create_sub_customer_without_stripe(@plan, @code)
          flash[:success] = "Thank you for using NameCoach! (No payment details were needed, and you have not been charged.) You can now create a Name Page, from which you can 1) invite attendees to record their names, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
          redirect_to current_user
   elsif is_valid_sub_coupon(@code) && !@planobject.nil?
          @coupon = Coupon.find_by_free_page_name(@code)
          @new_price = @planobject.annual_cost_cents * (100 - @coupon.percent_off)/100
          flash.now[:success] = "Your promo code has been applied!"
          render action: 'stripenewcustomer_edu'

    else #could not find that coupon
      @code = nil 
      @coupon = nil 
      @new_price = nil
      flash.now[:error] = "Sorry, not a valid promo code."
      render action: 'stripenewcustomer_edu'
    end
end 



def stripereceiver  #incoming from stripenewcustomer form
  # get the credit card details submitted by the form
    token = params[:stripeToken]
    plan = params[:plan]
    code = params[:code]
    new_price = params[:new_price]
    event_type = params[:event_type]


    #this needs to change to allow for canceled subs  
    # UPDATE: this is coming from stripenewcustomer, which is only accessible to NEW USERS - so won't need to change to allow for cancellations, and it will never be the case that user.customer = true already for this user
    if current_user.customer == true #user is already a customer  
                                      # this should not happen often b/c a customer won't have access to the sign-up link (but this will change when add single-use)      
      redirect_to current_user, notice: "You are already subscribed to our service. Your card was not charged."  

    else #user not already a customer 

        if create_customer(token, plan, code, new_price, event_type)
              #record stripe's (?) customer_id for this user
              # this helper is in users helper
          
          redirect_to current_user
        else
          if event_type == "reception"
            render 'stripenewcustomer'
          else 
            render 'stripenewcustomer_edu'
          end 
        end 

    end    
    

end 


def newcustomer_purchase
  @user = User.new 
  @number = params[:pnc][:number].to_i

  if signed_in?
    flash[:notice] = "Since you are already a registered user, please use this page to purchase Event Pages."
    redirect_to existing_user_purchase_path
  end 

end 

def newcustomercreate_purchase

    @user = User.new
    @user.email = params[:user][:email]
    @user.password=params[:user][:password]
    @user.password_confirmation=params[:user][:password_confirmation]
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @number = params[:user][:number].to_i  #this will pass in the @plan value into the stripenewcustomer_purchase page via the render 'stripenewcustomer_purchase' below (changed this from redirect, wasn't sure that would work)
    if @number.to_i < 6 
       @cost = @number.to_i*tier_one_price
       @price = "$#{tier_one_price}" 
    end 
    if @number.to_i > 5 && @number.to_i < 11 
       @cost = @number.to_i*tier_two_price
       @price = "$#{tier_two_price}"
    end 
    if @number.to_i > 10 
       @cost = @number.to_i*tier_three_price 
       @price = "$#{tier_three_price}"
    end 


    if @user.save

      sign_in @user
      # since user is new, won't have any PO with user_id; might have floating PO's with this email for some event, but those would be caught later when customer signs in for those events
      # when creates an event, can invite himself (at that email) to create a PO for that event for himself
      flash[:success] = "Thank you for registering.  Please fill in your payment details to finish subscribing."
      if @user.email == 'shanbhagp@aol.com'
          @user.customer = true
          @user.save
      end 
      if @user.email == 'startx@example.com'
          @user.customer = true
          @user.save
      end 
      if @user.email == 'teststartx@example.com'
          @user.customer = true
          @user.save
      end 
      render 'stripenewcustomer_purchase'  # i think @number defined in this action is being used on the stripenewcustomer_purchase rendering
    else

          if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
                        flash[:error] = "You are already registered on our site. Please sign in to purchase event pages under your Accounts tab."
                         redirect_to root_path
          else
              render action: 'newcustomer_purchase'
          end    

    end 

end 

def stripenewcustomer_purchase
   @number = 1 #just in case for some reason @number is not defined in the view, will have default value of '1'. 
end 

def changepur
  # @cost in DOLLARS
  @number= params[:pur][:number].to_i
    if @number.to_i < 6 
       @cost = @number.to_i*tier_one_price
       @price = "$#{tier_one_price}"
    end 
    if @number.to_i > 5 && @number.to_i < 11 
       @cost = @number.to_i*tier_two_price
       @price = "$#{tier_two_price}"
    end 
    if @number.to_i > 10 
       @cost = @number.to_i*tier_three_price
       @price = "$#{tier_three_price}"
    end 
   render action: 'stripenewcustomer_purchase'
end 


def coupon_purchase
    @coupon= params[:coup][:code]
    @number= params[:coup][:number].to_i  # just to preserve the number of pages in the purchase order

    if is_valid_single_use_coupon(@coupon)
          @price = "$#{tier_one_price}"
          @cost = Coupon.find_by_free_page_name(@coupon).cost  # IN DOLLARS
          flash.now[:success] = "Your promo code has been applied!"
          render action: 'stripenewcustomer_purchase'
      
    else #could not find that coupon
        #preserve the values (applies if someone tries to change the number of event pages after applying the code)
          if @number.to_i < 6 
             @cost = @number.to_i*tier_one_price 
             @price = "$#{tier_one_price}"
          end 
          if @number.to_i > 5 && @number.to_i < 11 
             @cost = @number.to_i*tier_two_price 
             @price = "$#{tier_two_price}"
          end 
          if @number.to_i > 10 
             @cost = @number.to_i*tier_three_price
             @price = "$#{tier_three_price}"
          end 
      @coupon = nil 
      flash.now[:error] = "Sorry, not a valid promo code."
      render action: 'stripenewcustomer_purchase'
    end

end 


def stripereceiver_purchase  #incoming from stripenewcustomer form
  # get the credit card details submitted by the form
    token = params[:stripeToken]
    number = params[:number].to_i
    coupon = params[:coupon] # this is the coupon code, a string
    cost = params[:cost]

    #this needs to change to allow for canceled subs - I think this is taken care of, no prior canceled subs for a true new customer(user)  

        if create_customer_purchase(token, number, cost, coupon)
              #record stripe's (?) customer_id for this user
              # this helper is in users helper
          
            #if the customer had a coupon, update that coupon to be inactive, and attach customer's user id to it
            if !coupon.blank?
              redeem_single_use_coupon(coupon)
            end 
          redirect_to current_user
        else
          render 'stripenewcustomer_purchase'
        end 
  
end 


def existing_user_purchase
  if customer_has_active_subscription?
      @subs = current_user.subscriptions 
      @s = @subs.active.first
      @s_year = @s.created_at + 365.days
  end 
  @pe = current_user.purchased_events

end 

# the checkout page, allowing a change to the order through existing_changepur below
def existing_user_purchase_select
  @number = params[:peu][:number].to_i
 
    if @number.to_i < 6  
       @cost = @number.to_i*tier_one_price
       @price = "$#{tier_one_price}" 
    end 
    if @number.to_i > 5 && @number.to_i < 11 
       @cost = @number.to_i*tier_two_price
       @price = "$#{tier_two_price}"  
    end 
    if @number.to_i > 10 
       @cost = @number.to_i*tier_three_price
       @price = "$#{tier_three_price}" 
    end 

    # if user is a stripe customer, want to allow him to use existing card
   if !current_user.customer_id.blank?  
     c = Stripe::Customer.retrieve(current_user.customer_id)
     @last4 = c.active_card.last4
     @cardtype = c.active_card.type
   end 

end 

def existing_changepur
  @number= params[:pur][:number].to_i
    if @number.to_i < 6 
       @cost = @number.to_i*tier_one_price
       @price = "$#{tier_one_price}" 
    end 
    if @number.to_i > 5 && @number.to_i < 11 
       @cost = @number.to_i*tier_two_price
       @price = "$#{tier_two_price}"
    end 
    if @number.to_i > 10 
       @cost = @number.to_i*tier_three_price
       @price = "$#{tier_three_price}" 
    end 

   # if user is a stripe customer, want to allow him to use existing card
   if !current_user.customer_id.blank?  
     c = Stripe::Customer.retrieve(current_user.customer_id)
     @last4 = c.active_card.last4
     @cardtype = c.active_card.type
   end 

   render action: 'existing_user_purchase_select'
end 


def existing_coupon_purchase
    @coupon= params[:coup][:code]
    @number= params[:coup][:number].to_i  # just to preserve the number of pages in the purchase order

     # if user is a stripe customer, want to allow him to use existing card
   if !current_user.customer_id.blank?  
     c = Stripe::Customer.retrieve(current_user.customer_id)
     @last4 = c.active_card.last4
     @cardtype = c.active_card.type
   end 


    if is_valid_single_use_coupon(@coupon)
          @price = "$#{tier_one_price}" 
          @cost = Coupon.find_by_free_page_name(@coupon).cost  # IN DOLLARS
          flash.now[:success] = "Your promo code has been applied!"
          render action: 'existing_user_purchase_select'
      
    else #could not find that coupon
        #preserve the values (applies if someone tries to change the number of event pages after applying the code)
          if @number.to_i < 6 
             @cost = @number.to_i*tier_one_price 
             @price = "$#{tier_one_price}" 
          end 
          if @number.to_i > 5 && @number.to_i < 11 
             @cost = @number.to_i*tier_two_price
             @price = "$#{tier_two_price}" 
          end 
          if @number.to_i > 10 
             @cost = @number.to_i*tier_three_price
             @price = "$#{tier_three_price}" 
          end 
      @coupon = nil 
      flash.now[:error] = "Sorry, not a valid promo code."
      render action: 'existing_user_purchase_select'
    end
end 

# use existing stripe card to purchase events
def purchase_events_existing_card

  @number = params[:peu][:number]
  coupon = params[:peu][:coupon] # this is the coupon name/code, a string
  cost = params[:peu][:cost]

  # retrieve stripe customer object (downstream from user having a customer_id)
  c = Stripe::Customer.retrieve(current_user.customer_id)
  
  if existing_customer_purchase_events_existing_card(@number, cost, coupon)
         #if the customer had a coupon, update that coupon to be inactive, and attach customer's user id to it
            if !coupon.blank?
              redeem_single_use_coupon(coupon)
            end 
      flash[:success] = "Thank you! You have purchased an additional #{@number} event pages."
      redirect_to current_user
  else #errors in processing the card shouldn't usually happen, because the card was originally ok.  Can test by using stripes card number that binds to customer but does not charge correctly.
          # YES THE REDIRECT WORKS WITH THAT STRIPE TESTING NUMBER
      redirect_to existing_user_purchase_path
  end 


  
end 

# stripe receiver for existing user and stripe customer purchasing events with new cc details
def purchase_events_new_card
    token = params[:stripeToken]
    @number = params[:number].to_i
    coupon = params[:coupon]
    cost = params[:cost]

        if update_card_and_purchase(token, @number, cost, coupon)
           #if the customer had a coupon, update that coupon to be inactive, and attach customer's user id to it
            if !coupon.blank?
              redeem_single_use_coupon(coupon)
            end 
          flash[:success] = "Thank you! You have purchased an additional #{@number} event pages."
          redirect_to current_user
        else
          redirect_to existing_user_purchase_path
        end 
end 

# stripe receiver for existing user who is not a stripe customer purchasing events (i.e., a new cc)
def purchase_events_new_stripe_customer
      token = params[:stripeToken]
      @number = params[:number].to_i
      coupon = params[:coupon]
      cost = params[:cost]

        if create_customer_and_purchase_existing_user(token, @number, cost, coupon) # this is almost like create_customer_purchase, except have flash.nows in that helper
           #if the customer had a coupon, update that coupon to be inactive, and attach customer's user id to it
            if !coupon.blank?
              redeem_single_use_coupon(coupon)
            end 
           redirect_to current_user
        else
          redirect_to existing_user_purchase_path
        end 

end


def macbeath
   render :layout => nil
end 

def macbeathindex
   render :layout => nil
end 

def login
end 


def grad_new_customer_purchase
  @user = User.new 
  @number = 1

  if signed_in?
    flash[:notice] = "Since you are already a registered user, please use this page to purchase Event Pages."
    redirect_to existing_user_purchase_path
  end 

end 


def grad_new_customer_create_purchase

    @user = User.new
    @user.email = params[:user][:email]
    @user.password=params[:user][:password]
    @user.password_confirmation=params[:user][:password_confirmation]
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.event_type = 'graduation'
    @number = 1 
    @cost = one_grad_price
    @price = "$#{one_grad_price}" 


    if @user.save

      sign_in @user
      # since user is new, won't have any PO with user_id; might have floating PO's with this email for some event, but those would be caught later when customer signs in for those events
      # when creates an event, can invite himself (at that email) to create a PO for that event for himself
      flash[:success] = "Thank you for registering.  Please fill in your payment details to finish subscribing."
      if @user.email == 'shanbhagp@aol.com'
          @user.customer = true
          @user.save
      end 
      if @user.email == 'startx@example.com'
          @user.customer = true
          @user.save
      end 
      if @user.email == 'teststartx@example.com'
          @user.customer = true
          @user.save
      end 
      render 'stripe_grad_new_customer_purchase'  # i think @number defined in this action is being used on the stripenewcustomer_purchase rendering
    else

          if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
                        flash[:error] = "You are already registered on our site. If not signed in already, please do so to purchase event pages under your Accounts tab."
                         render 'stripe_grad_new_customer_purchase'
          else
              render action: 'grad_new_customer_purchase'
          end    

    end 

end

def stripe_grad_new_customer_purchase
   if @number.nil?
        @number = 1 #just in case for some reason @number is not defined in the view, will have default value of '1'. 
   end 
end 

def grad_coupon_purchase 
    @coupon= params[:coup][:code]
    @number= params[:coup][:number].to_i  # just to preserve the number of pages in the purchase order

    if is_valid_free_coupon(@coupon) #could not find that coupon
        #preserve the values (applies if someone tries to change the number of event pages after applying the code)
          create_grad_customer_without_stripe(@coupon)
          flash[:success] = "Thank you for using NameCoach! (No payment details were needed, and you have not been charged.) You can now create an event page, from which you can 1) invite attendees to record their names, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
          redirect_to current_user

    # ORDER IMPORTANT HERE BC is_valid_free_coupon checks that coupon.name == 'free' but is_valid_single_use_coupon does not check coupon.name      
    elsif is_valid_single_use_coupon(@coupon)
          @price = "$#{one_grad_price}" 
          @cost = Coupon.find_by_free_page_name(@coupon).cost  # IN DOLLARS
                #max_redemptions is now being used for number of pages an promo code gets you when not defaulting to 1, like for Cecilia's sale
                if !Coupon.find_by_free_page_name(@coupon).max_redemptions.blank?
                  @number = Coupon.find_by_free_page_name(@coupon).max_redemptions
                else
                  @number = 1
                end 
          flash.now[:success] = "Your promo code has been applied!"
          render action: 'stripe_grad_new_customer_purchase'

    else
             @cost = one_grad_price
             @price = "$#{one_grad_price}" 
          
      @coupon = nil 
      flash.now[:error] = "Sorry, not a valid promo code."
      render action: 'stripe_grad_new_customer_purchase'
    end

end 

def grad_stripereceiver_purchase
    #incoming from stripenewcustomer form
  # get the credit card details submitted by the form
    token = params[:stripeToken]
    number = params[:number].to_i
    coupon = params[:coupon] # this is the coupon code, a string
    cost = params[:cost]

    #this needs to change to allow for canceled subs - I think this is taken care of, no prior canceled subs for a true new customer(user)  

        if grad_create_customer_purchase(token, number, cost, coupon)
              #record stripe's (?) customer_id for this user
              # this helper is in users helper
          
            #if the customer had a coupon, update that coupon to be inactive, and attach customer's user id to it
            if !coupon.blank?
              redeem_single_use_coupon(coupon)
            end 
          redirect_to current_user
        else
          render 'stripe_grad_new_customer_purchase'
        end 

end

#-------------------- Wedding page -------------------------------------------------------------------------
def wed_new_customer_purchase
  @user = User.new 
  @number = 1

  if signed_in?
    flash[:notice] = "Since you are already a registered user, please use this page to purchase Event Pages."
    redirect_to existing_user_purchase_path
  end 

end 


def wed_new_customer_create_purchase

    @user = User.new
    @user.email = params[:user][:email]
    @user.password=params[:user][:password]
    @user.password_confirmation=params[:user][:password_confirmation]
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.event_type = 'wedding'
    @number = 1  #this will pass in the @plan value into the stripenewcustomer_purchase page via the render 'stripenewcustomer_purchase' below (changed this from redirect, wasn't sure that would work)
    @cost = one_wed_price
    @price = "$#{one_wed_price}"


    if @user.save

      sign_in @user
      # since user is new, won't have any PO with user_id; might have floating PO's with this email for some event, but those would be caught later when customer signs in for those events
      # when creates an event, can invite himself (at that email) to create a PO for that event for himself
      flash[:success] = "Thank you for registering.  Please fill in your payment details to finish subscribing."
      if @user.email == 'shanbhagp@aol.com'
          @user.customer = true
          @user.save
      end 
      if @user.email == 'startx@example.com'
          @user.customer = true
          @user.save
      end 
      if @user.email == 'teststartx@example.com'
          @user.customer = true
          @user.save
      end 
      render 'stripe_wed_new_customer_purchase'  # i think @number defined in this action is being used on the stripenewcustomer_purchase rendering
    else

          if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
                        flash[:error] = "You are already registered on our site. If not signed in already, please do so to purchase event pages under your Accounts tab."
                         render 'stripe_wed_new_customer_purchase'
          else
              render action: 'wed_new_customer_purchase'
          end    

    end 

end

def stripe_wed_new_customer_purchase
   @number = 1 #just in case for some reason @number is not defined in the view, will have default value of '1'. 
end 

def wed_coupon_purchase 
    @coupon= params[:coup][:code]
    @number= params[:coup][:number].to_i  # just to preserve the number of pages in the purchase order

    if is_valid_free_coupon(@coupon) #could not find that coupon
        #preserve the values (applies if someone tries to change the number of event pages after applying the code)
          create_wed_customer_without_stripe
          flash[:success] = "Thank you for using NameCoach! (No payment details were needed, and you have not been charged.) You can now create an event page, from which you can 1) invite attendees to record their names, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
          redirect_to current_user

    # ORDER IMPORTANT HERE BC is_valid_free_coupon checks that coupon.name == 'free' but is_valid_single_use_coupon does not check coupon.name      
    elsif is_valid_single_use_coupon(@coupon)
          @price = "$#{one_wed_price}"
          @cost = Coupon.find_by_free_page_name(@coupon).cost  # IN DOLLARS
          flash.now[:success] = "Your promo code has been applied!"
          render action: 'stripe_wed_new_customer_purchase'

    else
             @cost = one_wed_price
             @price = "$#{one_wed_price}"
          
      @coupon = nil 
      flash.now[:error] = "Sorry, not a valid promo code."
      render action: 'stripe_wed_new_customer_purchase'
    end

end 

def wed_stripereceiver_purchase
    #incoming from stripenewcustomer form
  # get the credit card details submitted by the form
    token = params[:stripeToken]
    number = params[:number].to_i
    coupon = params[:coupon] # this is the coupon code, a string
    cost = params[:cost]

    #this needs to change to allow for canceled subs - I think this is taken care of, no prior canceled subs for a true new customer(user)  

        if wed_create_customer_purchase(token, number, cost, coupon)
              #record stripe's (?) customer_id for this user
              # this helper is in users helper
          
            #if the customer had a coupon, update that coupon to be inactive, and attach customer's user id to it
            if !coupon.blank?
              redeem_single_use_coupon(coupon)
            end 
          redirect_to current_user
        else
          render 'stripe_wed_new_customer_purchase'
        end 

end
#----------------------------------Wedding code ends ---------------------------------------------------------------


def demo_recorder
  @user = User.new
  render :layout => nil
  # necessary b/c having the rendered header was causing problems on the test page
end 


def demo_recorder_vg
  @user = User.new
  render :layout => nil
  # necessary b/c having the rendered header was causing problems on the test page
end 

def test5

  render :layout => nil
  # necessary b/c having the rendered header was causing problems on the test page
end 


end



