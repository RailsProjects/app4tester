class AdmininvitesController < ApplicationController
before_filter :signed_in_user, only: [:create]
before_filter :owner, only: [:index]

	def index
		@ais = Admininvite.all
	end

	#this action is called when admin submits form to invite another admin
	# creates an admininvite object, with token and event_id
	#sends invite email 
	
	 def create
	 	@ai = Admininvite.new
	    @ai.recipient_email = params[:admininvite][:recipient_email]
	    @ai.first_name = params[:admininvite][:first_name]
	    @ai.last_name = params[:admininvite][:last_name]
	    @ai.event_id = params[:admininvite][:event_id] 
	    @ai.admin_id = current_user.id
	    @event = @ai.event #make sure this code works, even though @ai has not been saved to db yet - checked in rails console, seems fine
			 	if User.find_by_email(@ai.recipient_email)#email on @ai is that of an existing user
			 		 u = User.find_by_email(@ai.recipient_email)
			 		 if @event.adminkeys.find_by_user_id(u.id) #existing user is registered as an admin for this event - notice that user already registered as an admin for this event
			 		 	 redirect_to @ai.event, notice: 'The person with this email address is already registered as an admin for this event.'
			 		 else #existing user is not registered as an admin for this event - create adminkey for this user/event, 
			 		 	  # notice that 'person with at email is a registered user on our site, and is now an admin for this event, and has been notified'
			 		 	  # send email that has been registered as an admin for this event
			 		 	  # set admin to true for this existing user 
			 		 	  # try to give a PO for this user for this event, if doesn't already have one. 
			 		 	    @ai.user_id = u.id
			 		 	    @ai.save  #update the @ai with the user_id of the existing user, and save
			 		 	    u.admin = true
					        u.save #update the existing user to be an admin - !!!might want to wrap this/try this, to try to avoid an exception, there shouldn't be, except for the missing names in the DB issue 
			 		 	 	@adminkey = Adminkey.new(event_id: @event.id, user_id: u.id)
				            if @adminkey.save 
				            	if !@event.practiceobjects.nil? && @event.practiceobjects.find_by_user_id(u.id) #check if PO exists for this event/user_id; if so..
				            		@to = @ai.recipient_email
	    							startx
				            		AdminInviteMailer.admin_notify(@ai, root_url, @to).deliver 
					            	redirect_to @ai.event, notice: 'The person at this email address is already registered on our site, is now registered as an admin for this event, and will be notified. '
				            	else  # PO does not exist for this event/user_id
				            		if !@event.practiceobjects.nil? &&  @event.practiceobjects.find_by_email(u.email) #check if PO exists for this event/em entered (if, say, there's a floating PO for this event for this existing user)
				            				#anchor PO to that user_id, and default to user attributes (already convered case of already existing PO for this user_id/event)
				            				@event.practiceobjects.find_by_email(u.email).update_attributes(:user_id => u.id, :recording => u.recording, :phonetic => u.phonetic, :notes => u.notes)
				            				@to = @ai.recipient_email
	    									startx
				            				AdminInviteMailer.admin_notify(@ai, root_url, @to).deliver 
					            			redirect_to @ai.event, notice: 'The person at this email address is already registered on our site, is now registered as an admin for this event, and will be notified. '
				            		else #PO does not exist for this event/em entered
				            			#create a new PO, send notification 
				            			@po = Practiceobject.new(:user_id => u.id, :event_id => @event.id, :email => u.email, :first_name => u.first_name, :last_name => u.last_name, :recording => u.recording, :notes => u.notes, :phonetic => u.phonetic)
				            			if @po.save  #this should save - already checked if user u had a PO for this event
					            			@to = @ai.recipient_email
	    									startx
					            			AdminInviteMailer.admin_notify(@ai, root_url, @to).deliver 
						            		redirect_to @ai.event, notice: 'The person at this email address is already registered on our site, is now registered as an admin for this event, and will be notified. '
						            	else #should'nt happen, but just in case
						            		@to = @ai.recipient_email
	    									startx
						            		AdminInviteMailer.admin_notify(@ai, root_url, @to).deliver 
					            			redirect_to @ai.event, notice: 'The person at this email address is already registered on our site, is now registered as an admin for this event, and will be notified. '
						            	end 
				            		end 
				            	end 
				           		#if event's customer has a master list, give the invited admin a master list adminkey
				           		# and forget about the PO nonsense above
				           		make_master_admin(@event, u)	
				            else #only reason for adminkey not to save is if there's already an admin key for this user/event combo - a case we already covered, so this is throw-away I think- i.e., will never be a case
				            	 redirect_to @ai.event, notice: 'The person at this email address is already registered as an admin for this event.'
				            end 
				      	  


			 		 end 
			 	else #email on @ai is not that of existing user - execute original code
			 		if @ai.save  
				     	#AdminInviteMailer.admin_invitation(@ai, new_user_url(:token => @practiceobject.token), @practiceobject).deliver 
				     	@to = @ai.recipient_email
	    				startx
				     	AdminInviteMailer.admin_invitation(@ai, adminsignup_url(:token => @ai.token), @to).deliver 
				     	redirect_to @ai.event, notice: 'Admin has been invited for this event.'
			 	 	else
				 	 	redirect_to @ai.event, notice: 'Something went wrong - please make sure to enter valid email address'
				 	 	# see if we can use render here (how to do that?) and thereby get the validation errors
			 		 end
			 	end 
		    	
	 end



		    	
	 def vg_admininvite
	 	@ai = Admininvite.new
	    @ai.recipient_email = params[:vgai][:recipient_email]
	    @ai.first_name = params[:vgai][:first_name]
	    @ai.last_name = params[:vgai][:last_name]
	    @ai.event_id = params[:vgai][:event_id] 
	    @ai.admin_id = current_user.id
	    @event = @ai.event #make sure this code works, even though @ai has not been saved to db yet - checked in rails console, seems fine
			 	if User.find_by_email(@ai.recipient_email)#email on @ai is that of an existing user
			 		 u = User.find_by_email(@ai.recipient_email)
			 		 if @event.adminkeys.find_by_user_id(u.id) #existing user is registered as an admin for this event - notice that user already registered as an admin for this event
			 		 	 redirect_to @ai.event, notice: 'The person with this email address is already registered as an admin for this event.'
			 		 else #existing user is not registered as an admin for this event - create adminkey for this user/event, 
			 		 	  # notice that 'person with at email is a registered user on our site, and is now an admin for this event, and has been notified'
			 		 	  # send email that has been registered as an admin for this event
			 		 	  # set admin to true for this existing user 
			 		 	  # try to give a PO for this user for this event, if doesn't already have one. 
			 		 	    @ai.user_id = u.id
			 		 	    @ai.save  #update the @ai with the user_id of the existing user, and save
			 		 	    u.admin = true
					        u.save #update the existing user to be an admin - !!!might want to wrap this/try this, to try to avoid an exception, there shouldn't be, except for the missing names in the DB issue 
			 		 	 	@adminkey = Adminkey.new(event_id: @event.id, user_id: u.id)
				            if @adminkey.save
				            	adminvoicegem(u)
				            	@to = @ai.recipient_email
				            	startx
				            	AdminInviteMailer.vg_admin_notify(@ai, root_url, @to).deliver 
					            redirect_to @ai.event, notice: 'The person at this email address is already registered on our site, is now registered as an admin for this event, and will be notified. '
				           
				            else #only reason for adminkey not to save is if there's already an admin key for this user/event combo - a case we already covered, so this is throw-away I think- i.e., will never be a case
				            	 redirect_to @ai.event, notice: 'The person at this email address is already registered as an admin for this event.'
				            end 
				      	  


			 		 end 
			 	else #email on @ai is not that of existing user - execute original code
			 		if @ai.save  
				     	#AdminInviteMailer.admin_invitation(@ai, new_user_url(:token => @practiceobject.token), @practiceobject).deliver 
				     	@to = @ai.recipient_email
	    				startx
				     	AdminInviteMailer.vg_admin_invitation(@ai, adminsignup_url(:token => @ai.token), @to).deliver 
				     	redirect_to @ai.event, notice: 'Admin has been invited for this event.'
			 	 	else
				 	 	redirect_to @ai.event, notice: 'Something went wrong - please make sure to enter valid email address'
				 	 	# see if we can use render here (how to do that?) and thereby get the validation errors
			 		 end
			 	end 
	 end 




	 #this action is called when rendering the form for admin signup
	 # this takes in the token from the url, passes it through the form as what?
	 # a temp attribute of the new user object?  then would need form_for(@user)
	 # try overriding default: e.g., <%= form_for(@post, :url => super_posts_path) do |f| %>
	 def adminsignup
	 	if signed_in? 
	 		redirect_to root_path
	 	else
		 	@user = User.new(:invite_token => params[:token])
	          if  Admininvite.find_by_token(@user.invite_token)
	               @ai = Admininvite.find_by_token(@user.invite_token)
	               @user.email = @ai.recipient_email
	               @user.first_name = @ai.first_name
	               @user.last_name = @ai.last_name 
	               #this is some polish to automatically set the email field in the form
	               #flash[:notice] = "You have been invited, please sign up to be an admin!"
	               #put this back in later when you've figured out the flash/notice thing, included notices inthe application layout
	               @event = Event.find_by_id(@ai.event_id) 
	          else
	          	redirect_to root_path, notice: 'Admin signup by invitation only, please sign up here. If you are following a link and have already signed up, please sign in.'
	          	#doesn't check to see if admin invite already used, b/c in adminusercreate, we are not re-saving and changing the admininvite token upon 
	          	#user save, as we do with the practiceobject token for invited user signup. 
	          end
	    end
      #maybe check to see first if there is a token passed in: if params[:token].any? or something; or rather, if
      # the @user already has a :token attribute b/c rendered from a failed create attempt below
      #actually, it seems that users are still being appropriately assoaciated with their practice objects even when they mess up the invited 
      # signup  - I think somehow the token is being passed in here from the failed sign-up as params[:token]? (associated with incoming @user object, which
        #hasn't been reset yet (available to be assigned once more to @user)) no, that seems unlikely since the associated user attribute is
      #invite_token, not token.
      #ANSWER:  we are just re-rendering new, not hitting the new action - none of the new action logic is being executed - @user still has all it's associated
      #fields, including the :invite_token.  
	 end

	 #this action is called when the admin signup form is submitted and the admin user is created,
	 # and adminkey object with user_id and event_i

def adminusercreate
	 	    @user = User.new
		    @user.email = params[:user][:email]
		    @user.password=params[:user][:password]
		    @user.password_confirmation=params[:user][:password_confirmation]
			@user.invite_token = params[:user][:invite_token] 
			@user.admin = true 
			@user.first_name = params[:user][:first_name]
    		@user.last_name = params[:user][:last_name]
			
    if @user.save  then  #if the user already exists (same email), will be forced to try the addadmin action (we get the rerendered admin signup form with
    					 #  errors; although might be nice to give the user a notice to 'sign in to the right')
            sign_in @user
            #set the adminkey for that user and the event he was invited to admin for  
            	if Admininvite.find_by_token(@user.invite_token) # probably not necessary, but just to avoid nomethod on nil errors from not finding the @ai
		            @ai = Admininvite.find_by_token(@user.invite_token)
		            @event = @ai.event
		            @adminkey = Adminkey.new(event_id: @event.id, user_id: @user.id)
		            @adminkey.save
		            #link the admin invite to the user just created
		            @ai.update_attributes(user_id: @user.id)

		            make_master_admin(@event, @user)	

		            if  bigdaddyevent
						adminvoicegem(@user)
						redirect_to @user, notice: "Welcome to NameCoach's new VoiceGem service, and thanks for registering to admin this event, #{@event.title}.  Click on your event to request and hear VoiceGems.  And create or update your own VoiceGem."
				     else
				     	adminpracticeobject
				     	#templates (redirects) in this helper
				     end  		
		        else #couldn't find the ai by token
		        	redirect_to @user, notice: 'There was an error. Invitation code was invalid. Please sign out and try again.'
		        end 
    else
        	  if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
              flash.now[:error] = 'You have previously registered on our site. Please sign in here.' 
         	  end 
        	  if  Admininvite.find_by_token(@user.invite_token)
	               @ai = Admininvite.find_by_token(@user.invite_token)
	               #@user.email = @ai.recipient_email
	               #@user.first_name = @ai.first_name
	               #@user.last_name = @ai.last_name 
	               #this is some polish to automatically set the email field in the form; but I've commented them out b/c should be coming in from @user set in the beginning of this action anyway
	               #flash[:notice] = "You have been invited, please sign up to be an admin!"
	               #put this back in later when you've figured out the flash/notice thing, included notices inthe application layout
	                @event = Event.find_by_id(@ai.event_id)
	          end #this if-end can be taken out if it causes problems
	         
            render 'adminsignup'
            #this still passes in the invite_token with the @user (b/c it's already set, not using params[token] this time), if there is one; so a failed save for an invited admin can still work.  But since the action adminusercreate has been hit
            # now, we have lost the @ai istance variable set on the adminsignup page. This is fixed by the if-end statement above
            #note the 'render action' DOES NOT hit the action! (I"m pretty sure).  It only renders the view!  I've changed it here to the equivalent render 'adminsignup'
    end

end #adminusercreate end 



end  #controller end
