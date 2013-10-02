class EventsController < ApplicationController
	before_filter :signed_in_user, only: [:create, :show, :index, :edit, :update, :destroy, :voicegems, :directory]
	before_filter :correct_admin_or_user, only: [:show, :voicegems]
	before_filter :correct_admin, only: [:edit]
	before_filter :active_page_check, only: [:show]

    before_filter :owner, only: [:index, :destroy]

	#def new
	#	 @event = Event.new  
	#end
	# this action is now no longer used, as the form is embedded in the user's (customer's) show page

	def create
	     @event = Event.new(params[:event])
	     @user = current_user
	     assign_event_type(@event) 

	     if  @event.purchase_type == 's'
	     	 if customer_has_active_subscription? && sub_pages_left > 0  #double-check to see if has some sub pages
	     	 #maybe can take out, because can control for checking if has pages left in the customer_show view event creation well
		     	 # RUN MODIFIED FOR subscription events EXISTING CODE
	                 #generate the event_code 
	                 if @event.event_code.blank?
	                  generate_event_code(@event)
	                    if  @event.save  
	                    	#try decrementing s
            		          @s = current_user.subscriptions.select {|s| s.active == true}.first
					          @s.decrement(:events_remaining)
					          @s.increment(:events_used)
					          if @s.save
					          	 @event.customerkeys.create!(user_id: current_user.id)
	                    		 @event.adminkeys.create!(user_id: current_user.id)
	                    		if @event.master == true
	                    			flash[:success] = "You have created your Student Name Directory!"
	                    			redirect_to master_set_path(:id => @event.id)
	                    		else
	                     		    redirect_to @event, notice: "Welcome to your name page for #{@event.title}."
	                     		end 
					          else #should't happen because subscription should save
					            flash[:error] = 'Something went wrong.  Please try again or contact tech support.'
					            redirect_to current_user
					          end  
					        # end try decrementing s

					        #create default grad page if this is the master list
					       # create_default_grad_page(@event)
		                else
		                  flash[:error] = 'Please enter a title and date.'
		                  redirect_to current_user
		                end

	                 else
	                  if Event.find_by_event_code(@event.event_code.upcase.delete(' '))
	                         redirect_to current_user, notice: "This code,#{@event.event_code.upcase.delete(' ')}, has already been taken. Please choose another."
	                  else 
	                        e = @event.event_code.upcase.delete(' ')
	                        @event.event_code = e 
	                        if  @event.save  
		                    	#try decrementing s
	            		          @s = current_user.subscriptions.select {|s| s.active == true}.first
						          @s.decrement(:events_remaining)
						          @s.increment(:events_used)
						          if @s.save
						          	 @event.customerkeys.create!(user_id: current_user.id)
		                    		 @event.adminkeys.create!(user_id: current_user.id)
		                     		 redirect_to @event, notice: "Welcome to your name page for #{@event.title}."
						          else #should't happen because subscription should save
						            flash[:error] = 'Something went wrong.  Please try again or contact tech support.'
						            redirect_to current_user
						          end  
						        # end try decrementing s
	                      	else
	                      	redirect_to current_user, notice: 'Please enter a title and date.'
	                      	end
	                end 
	              end 
	             #END RUN MODIFIED for subscription events EXISTING CODE

	     	 else #shouldn't happen because event creation well shouldn't allow incoming s event_type if no s pages are left
	     	 	flash[:error] = 'No name pages remaining.  Please purchase more or upgrade your plan.'
	     		redirect_to current_user
	     	 end 
	     else
	     	if @event.purchase_type == 'p'
	     		if @user.purchased_events > 0
			     	     # RUN MODIFIED for purchased events EXISTING CODE
		                 #generate the event_code 
		                 if @event.event_code.blank?
		                  generate_event_code(@event)
		                    if  @event.save  
		                    	# try decrementing p
		                    	 @user.decrement(:purchased_events)
           						 if @user.save
           						      @event.customerkeys.create!(user_id: current_user.id)
		                     		  @event.adminkeys.create!(user_id: current_user.id)
		                     		  redirect_to @event, notice: "Welcome to your name page for #{@event.title}."
								 else #shouldn't happen because @user should save
					                  flash[:error] = 'Something went wrong.  Please try again or contact tech support.'
					                  redirect_to current_user
           						 end 
           						 # END try decrementing p
		                  else
		                  flash[:error] = 'Please enter a title and date.'
		                  redirect_to current_user
		                  end

		                 else
		                  if Event.find_by_event_code(@event.event_code.upcase.delete(' '))
		                         redirect_to current_user, notice: "This  code,#{@event.event_code.upcase.delete(' ')}, has already been taken. Please choose another."
		                  else 
		                        e = @event.event_code.upcase.delete(' ')
		                        @event.event_code = e 
		                        if  @event.save  
			                    	# try decrementing p
			                    	 @user.decrement(:purchased_events)
	           						 if @user.save
	           						      @event.customerkeys.create!(user_id: current_user.id)
			                     		  @event.adminkeys.create!(user_id: current_user.id)
			                     		  redirect_to @event, notice: "Welcome to your name page for #{@event.title}."
									 else #shouldn't happen because @user should save
						                  flash[:error] = 'Something went wrong.  Please try again or contact tech support.'
						                  redirect_to current_user
	           						 end 
	           						 # END try decrementing p
		                      else
		                      redirect_to current_user, notice: 'Please enter a title and date.'
		                      end
		                end 
		              end 
		             #END RUN MODIFIED for purchased pages EXISTING CODE


	     			
	     		else #shouldn't happen because event creation well shouldn't allow incoming p event_type if no p pages are left
	     			flash[:error] = 'No name pages remaining.  Please purchase more or upgrade your plan.'
	     	 		redirect_to current_user
	     		end
	     	else #this shouldn't happen, just a catch all in case an event_type comes in that isn't p or s
	     		flash[:error] = 'Something went wrong.  Please try again or contact tech support.'
	     		redirect_to current_user
	     	end 
	     end 



	end

	def show

		 @event = Event.find(params[:id])
		 @individual = individual(@event) # for setting the language in the show page

		 if @event.master == true
		 	flash.keep
		 	redirect_to directory_event_path(@event)
		 end 

		 unless current_user.email == 'shanbhagp@aol.com'
		 	@owner = false
		 end 

		 # for rendering different text in the view  
		 # not currently using this if-else-end
		# if student_event?  
		 #	@person = "Student"
		 #else
		 #	@person = "Attendee"
		# end 
		 
		 if bigdaddyevent
		 	
		 	 @registeredandrecordedvgs = @event.voicegems.registered.recorded.visible
			 @registeredandunrecordedvgs = @event.voicegems.registered.unrecorded.visible
			 @unregisteredvgs = @event.voicegems.unregistered.visible
			 @hiddenvgs = @event.voicegems.hidden
			 @hiddenandregisteredvgs  = @hiddenvgs.registered
			 @hiddenandunregisteredvgs = @hiddenvgs.unregistered  

			 @url = vgrecord_url(:event_code => @event.event_code)


		 	render action: 'voicegems'
		 else
			 @practiceobject = Practiceobject.new  
			 @practiceobject.event_id = @event.id #for the form_for(@practiceobject) which creatse a new practice object (and another form which just shows the labels - can find a better way for that)
			 @registeredandrecordedpos = @event.practiceobjects.registered.recorded.visible
			 @registeredandunrecordedpos = @event.practiceobjects.registered.unrecorded.visible
			 @unregisteredpos = @event.practiceobjects.unregistered.visible
			 @hiddenpos = @event.practiceobjects.hidden
			 @hiddenandregisteredpos  = @hiddenpos.registered
			 @hiddenandunregisteredpos = @hiddenpos.unregistered  

			 @url = record_url(:event_code => @event.event_code)
			 @url2 = locked_event_url(@event)
		end 
    end

def directory

		 @event = Event.find(params[:id])
		 @adminevents = current_user.adminevents
		 @adminevents.delete_if {|item| item == @event} #remove this event page (master list) from drop down for migration
		 #map to a titles array
		#@admineventtitles = Array.new
		 #@adminevents.each do |a|
		 #	unless a.id == @event.id
		 #		@admineventtitles.push a.title
		 #	end 
		 #end 

		 #@admineventsarray = Array.new
		 #create array of array
		 # @adminevents.each do |a|
		 	#unless a.id == @event.id
		 	#	@array = Array.new
		 	#	@array.push a.id
		 	#	@array.push a.title
		 	#	@admineventsarray.push @array
		 #	#end 
		# end 

		 #take out master list from this array
		 #@adminevents.delete_if {|item| item == @event}

		  @individual = individual(@event) # for setting the language in the show page
		 
		 unless current_user.email == 'shanbhagp@aol.com'
		 	@owner = false
		 end

			 @practiceobject = Practiceobject.new  
			 @practiceobject.event_id = @event.id #for the form_for(@practiceobject) which creatse a new practice object (and another form which just shows the labels - can find a better way for that)
			 @registeredandrecordedpos = @event.practiceobjects.registered.recorded.visible
			 @registeredandunrecordedpos = @event.practiceobjects.registered.unrecorded.visible
			 @unregisteredpos = @event.practiceobjects.unregistered.visible
			 @hiddenpos = @event.practiceobjects.hidden
			 @hiddenandregisteredpos  = @hiddenpos.registered
			 @hiddenandunregisteredpos = @hiddenpos.unregistered  

			 @url = record_url(:event_code => @event.event_code)

    end


    #alternate event show page for bigdaddy;  instance variables already set in 'show' above
    def voicegems
    end 


	def index
    @events = Event.all
  end

  def edit
  	@event = Event.find(params[:id])
  	
  end 


  def update
    @event = Event.find(params[:id])
    
    @event.title = params[:event][:title]
    @event.date = params[:event][:date]

    if params[:event][:event_code].blank? 
    	generate_event_code(@event)
 		if  @event.save  
 		  flash[:success] =  "Your event details were updated."
	      redirect_to @event
	 	else
	 	 flash[:error] = 'Please make sure both a title and date are entered for your event.'
	 	 redirect_to edit_event_path(@event)
	 	end
    else
		if Event.find_by_event_code(params[:event][:event_code].upcase.delete(' ')) && !(Event.find_by_event_code(params[:event][:event_code].upcase.delete(' ')).id == @event.id)
			flash[:error] = "This event code, #{params[:event][:event_code].upcase.delete(' ')}, has already been taken. Please choose another."
		    redirect_to edit_event_path(@event)
		else 
     		@event.event_code = params[:event][:event_code].upcase.delete(' ') 
		    if  @event.save 
		     flash[:success] = "Your event details were updated."
		     redirect_to @event
		 	else
		 	  flash[:error] = 'Please make sure both a title and date are entered for your event.'
	 	      redirect_to edit_event_path(@event)
		 	end
		end 

    end 


  end


 def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end


 def record
 	if signed_in?
 		flash[:success] = "Trying to record your name or edit your NameGuide? Please do so below."
 		redirect_to current_user 
 	end 
 		
 	@event_code = params[:event_code]

 	if Event.find_by_event_code(@event_code)
 	 @event = Event.find_by_event_code(@event_code)
 	 @user = User.new

 	else
 	flash[:error] = "We were not able to find your event.  Please contact NameCoach or the admin for your event."
 		redirect_to root_path 
 	end 


 end

#def vgrecord
# moved to voicegems controller
#end 


def event_link_create  #for new users signing up from an event code link
    @user = User.new
    @user.email = params[:user][:email] unless params[:user].nil? #don't retrieve if no user
    @pw = SecureRandom.urlsafe_base64
    @user.password=@pw
    @user.password_confirmation=@pw
    @user.first_name = params[:user][:first_name] unless params[:user].nil?
    @user.last_name = params[:user][:last_name] unless params[:user].nil?
    @user.phonetic = params[:user][:phonetic] unless params[:user].nil?
    @user.notes = params[:user][:notes] unless params[:user].nil?
    @user.event_code = params[:user][:event_code] unless params[:user].nil?
    @user.grad_date = params[:user][:grad_date] unless params[:user].nil?
    @user.company = params[:user][:company] unless params[:user].nil?

    @event_code = params[:user][:event_code] unless params[:user].nil?

          #moved this up here so that what user entered is left in tact when re-renders form, and can take out @user = User.new below 

	if !params[:user].nil? && !params[:user][:event_code].blank? #see if any code parameter is passed incoming from the form - don't want to run this code if not, i.e., if user is signing up                from an inviation token
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
	                      #flash[:success] = "Now just record your name for #{@event.title}, and you're done!"
	                      redirect_to record_step2_path(:user => @user, :po => @po, :event => @event)
	                  else #no floating PO's associated with this email for this event (from an 'invite attendee' invitation), so give a new PO
	                        @po = Practiceobject.new(:user_id => @user.id, :event_id => @event.id, :email => @user.email, :first_name => @user.first_name, :last_name => @user.last_name, :phonetic => @user.phonetic, :notes => @user.notes) #needed to add email to PO to make sure PO saves, b/c of PO validations}
	                        if @po.save  #should be fine - since this is a new user, there can't be a PO for this event with his ID - true, but            #still problem if ADMIN ALSO INVITED AT THAT EMAIL ADDRESS, THEREBY CREATING A PO, AND USER HASN'T            #REGISTERED YET
	                           #flash[:success] = "Now just record your name for #{@event.title}, and you're done!"
	                           redirect_to record_step2_path(:user => @user, :po => @po, :event => @event, :event_code => @event_code)
	                        else #already a PO for this user_id and event, but this shouldn't happen since it's a new user
	                          redirect_to @user, notice: "Thanks for registering. However, something may have gone wrong - please contact your admin for #{@event.title} to see if they can view your NameGuide/recording. Otherwise, please contact NameCoach for support."
	                        end 
	                  end 

	                anchor_and_update_pos(@po)  #for achoring PO's created by inviting people for other events, who haven't registered as users yet
	                copy_to_master(@po, @event)  #for copying the new PO to the master list if the @event here is a sublist.

	            else # user already exists, or otherwise didn't validate as user
	                  #redirect back to this sign-up form - should render errors; if it's because ther user already exists, this is covered by the 
	                  # sign-in form on form, but maybe good to check first and tell user to sign-in.  Notice: "If you have already registered, please sign in under 'Already Registered.'""
	                    if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
	                            
								if signed_in? #perhaps pressing back button from record_step2 to change name or email?
											#users may never get here because we check signed_in? in the record action
									if !@user.recording.blank? #has already recorded.  Just take them to their profile page
										flash[:error] = "If you wish to update your recording or NameGuide, please do so on this page."
										redirect_to current_user	
									else #has not recorded - so take them to the recording page (record_step2) again
										flash[:error] = "Please record your name. If you wish to edit your name/email or NameGuide, do so on your profile page after you record your name."
										redirect_to record_step2_path(:user => @user, :event => @event, :event_code => @event_code)
	                    			end 
	                    		else #probably trying to register from record page with an existing email
	                            	flash[:error] = "This email (#{@user.email}) is already registered on our site. Please sign in under 'Already Registered?' (below) to register for this Name Page. If you didn't set or forgot your password, please click 'Reset Password' above."
	                                redirect_to record_path(:event_code => @event_code) 
	                            end 
	                    else #email not registered; so probably user info didn't validate - maybe forgot a field, or bad email address
	                             flash[:error] = "Please be sure to enter your first name, last name, and valid email address.  If you are prompted to select a graduation date/program, please do so."
	                    	     redirect_to record_path(:event_code => @event_code) 
	                    end 

	                    
	                    
	            end   
	    else #code entered doesn't exist for any event
	      #@user = User.new #for the re-rendering of the eventcodesignup view
	      #render this action again, with the flash message
	      flash[:error] = 'Something went wrong. Please contact NameCoach for support, or click on the link you received again.'
	      redirect_to record_path(:event_code => @event_code) 
	    end 
	else #no user parameters or no user event_code parameters
	  #@user = User.new #for the re-redering of the eventcodesignup view
	  #run existing users#create code - maybe make this a helper method
	  # or make this whole code a separate controller action, and just redirect to the form saying no code was entered
	  
	  # problem: code ends here, user cannot retry. One solution is to redirect back to event link
	  flash[:error] = 'Have you filled in all basic info? If problem persists, please contact support@name-coach.com'
	  redirect_to record_path(:event_code => @event_code) 
	  
	  
	end

end

def record_step2  #should never be hit if user is not signed in - so maybe before filter this.
	flash.keep
	@user = current_user

	#note that these incoming parameters are integers, not the model objects themselves - so can't set them to the model objects directly.
	#@po = Practiceobject.find(params[:po]) #probably don't need this?

	#@event = Event.find(params[:event]) #probably don't need this either? DO need this for iolani helper called in record_step2 html, which uses @event intance originally coming directly from event_link_create action
	# if don't need these last two, then don't need to have changed the renders to redirects to record_step2 in event_link_create?

 	 	#for settong @po if pressed back from record_step2 and then submits or presses forward
 	 # 	if !@event.practiceobjects.blank? && @event.practiceobjects.find_by_user_id(@user.id)  #there is an already a PO with user's em for this event, floating; in this
 	  		# case, probably b/c user pressed back button from record_step2  
	 #        @po = @event.practiceobjects.find_by_user_id(@user.id)
	#	end
		#but probably don't need to set @po anyway - not used in record_step2 view or helpers called in the view

	# just in case this is needed somehwere, since it's set in event_link_create as well
	#@event_code = params[:event_code]
end


def event_code_add  #this is for registering to record with an event link, for an existing user
      user = User.find_by_email(params[:session][:email].downcase.strip)
      @event_code = params[:session][:event_code]

     if user && user.authenticate(params[:session][:password]) then
        sign_in user
        if Event.find_by_event_code(@event_code.upcase.delete(' '))  #find event
             @event  = Event.find_by_event_code(@event_code.upcase.delete(' '))
            if   !@event.practiceobjects.nil? && @event.practiceobjects.find_by_user_id(user.id) #see if there's already a PO for this user_id and event (which should be this @po, if there is one)  (this covers the case in which signs up with a code, then the invitation link)
                  #trying to avoid no method on nil errors
                  redirect_to user, notice: "It looks like you are already registered for #{@event.title}. Please ensure you've uploaded your name recording."

            else #there's no PO for this user_id and event
                 #forego checking for a floating PO with this user's em (x), and assume we already have it with @po. If there is a floating PO with users's em address(x), 
                 #that's diffrent from the em of this @po (y), it's probably because the user got this invitation at an em address(y) that's different from
                 # the one he chose when signing up (x).  That's fine, we want to stick to the PO's.  Plus, that email difference will be displayed in the practice page. 
                       #@po.first_name = user.first_name  -- keep the names the admin entered when sent the invite
                        #@po.last_name = user.last_name
                        @po = Practiceobject.new
                        @po.event_id = @event.id
                        @po.user_id = user.id
                        @po.first_name = user.first_name
                        @po.last_name = user.last_name
                        @po.email = user.email
                        @po.recording = user.recording # need to default to user's recording if has a recording. !!! Need to update this when have multipler PO recordings for a user
                        @po.notes = user.notes #default to user attribute
                        @po.phonetic = user.phonetic # default to user attribute
                        # we don't update @po.email with user.email b/c want to display where invitation was sent
                          if  @po.save #save would fail if user already has a PO for this event;  NOTE: just relying on the unique pair index threw an exception; intead, adding a uniqueness validation in the model works (the save fails and redirects appropriately)
                                       #but save can take an existing PO for this user, which he's already updated via signing up with a code, and reset it -
                                       #admin invites user at email x, x signs up with code, x then signs in with invite link  - UPDATE: this is now fixed with code above
                          redirect_to user, notice: "Thank you for registering as an attendee for #{@event.title}.  Please make sure to create or update your NameGuide for this event."
                            # Sign the user in and redirect to the user's show page. 
                          else #this applies to any user (admin or attendee) who already has a PO for that event; this case now already covered, i.e., PO should save
                           redirect_to user, notice: "It looks like you are already registered for #{@event.title}. Please ensure you've uploaded your name recording."
                            # Sign the user in and redirect to the user's show page.
                         end
                       # else here would apply if there's a bad or no token passed in when trying to sign-in to sign-up.
                       # but note that by coming to users/new without a token or a valid token, new action will just say 'invalid token' already
                       # if the user has no credentials to begin with, it will just say invalid password if he's invited with a token but tries the sign-in to sign-up.
            
                       copy_to_master(@po, @event)
            end 

        else #do we need an else statement in case can't find the PO by token?
          redirect_to user, notice: "There was an error. Please sign out and try again, or contact NameCoach for support."
        end  
   
    else #invalid email/pw
      @user = User.new 
      @event = Event.find_by_event_code(@event_code.upcase.delete(' '))
      flash.now[:error] = 'Invalid email/password combination'
      render action: 'record'
    # Creates an error message and re-render the signin form.

     end
  end 

  def demo_event_page
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

  def demo_wedding_page
  	@event = Event.find(ENV['demopage'].to_i)

  	 @practiceobject = Practiceobject.new  
	 @practiceobject.event_id = @event.id #for the form_for(@practiceobject) which creatse a new practice object (and another form which just shows the labels - can find a better way for that)
	 @registeredandrecordedpos = @event.practiceobjects.registered.recorded.visible
	 @registeredandunrecordedpos = @event.practiceobjects.registered.unrecorded.visible
	 @unregisteredpos = @event.practiceobjects.unregistered.visible
	 @hiddenpos = @event.practiceobjects.hidden
	 @hiddenandregisteredpos  = @hiddenpos.registered
	 @hiddenandunregisteredpos = @hiddenpos.unregistered  

	 @url = demo_record_wedding_url(:event_code => @event.event_code)

	 
  end

  def demo_directory
  	@event = Event.find(ENV['demopage'].to_i)

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

  def demo_record

    @event_code = params[:event_code]
 	if Event.find_by_event_code(@event_code)
 	 @event = Event.find_by_event_code(@event_code)
 	 @user = User.new
 	else
 	flash[:error] = "We were not able to find your event.  Please contact NameCoach or the admin for your event."
 	redirect_to root_path 
 	end 

  end 


  def demo_record_temp

    @event_code = params[:event_code]
 	if Event.find_by_event_code(@event_code)
 	 @event = Event.find_by_event_code(@event_code)
 	 @user = User.new
 	else
 	flash[:error] = "We were not able to find your event.  Please contact NameCoach or the admin for your event."
 	redirect_to root_path 
 	end 

  end 

  def demo_record_wedding

    @event_code = params[:event_code]
 	if Event.find_by_event_code(@event_code)
 	 @event = Event.find_by_event_code(@event_code)
 	 @user = User.new
 	else
 	flash[:error] = "We were not able to find your event.  Please contact NameCoach or the admin for your event."
 	redirect_to root_path 
 	end 

  end 


  def demo_record_directory

    @event_code = params[:event_code]
 	if Event.find_by_event_code(@event_code)
 	 @event = Event.find_by_event_code(@event_code)
 	 @user = User.new
 	else
 	flash[:error] = "We were not able to find your event.  Please contact NameCoach or the admin for your event."
 	redirect_to root_path 
 	end 

  end 


 def BioE
 	 @event = Event.find(ENV['BioE'].to_i)

  	 @practiceobject = Practiceobject.new  
	 @practiceobject.event_id = @event.id #for the form_for(@practiceobject) which creatse a new practice object (and another form which just shows the labels - can find a better way for that)
	 @registeredandrecordedpos = @event.practiceobjects.registered.recorded.visible
	 @registeredandunrecordedpos = @event.practiceobjects.registered.unrecorded.visible
	 @unregisteredpos = @event.practiceobjects.unregistered.visible
	 @hiddenpos = @event.practiceobjects.hidden
	 @hiddenandregisteredpos  = @hiddenpos.registered
	 @hiddenandunregisteredpos = @hiddenpos.unregistered 
	 @gradpos = @registeredandrecordedpos.where("admin_notes = ? OR admin_notes = ?", 'PhD', 'MS') 
	 @undergradpos = @registeredandrecordedpos.where("admin_notes = ? OR admin_notes = ?", 'BS', 'BSH') 

	 @url = record_url(:event_code => @event.event_code)
 end


def locked
   @event = Event.find(params[:id])
     @practiceobject = Practiceobject.new  
	 @practiceobject.event_id = @event.id #for the form_for(@practiceobject) which creatse a new practice object (and another form which just shows the labels - can find a better way for that)
	 @registeredandrecordedpos = @event.practiceobjects.registered.recorded.visible
	 @registeredandunrecordedpos = @event.practiceobjects.registered.unrecorded.visible
	 @unregisteredpos = @event.practiceobjects.unregistered.visible
	 @hiddenpos = @event.practiceobjects.hidden
	 @hiddenandregisteredpos  = @hiddenpos.registered
	 @hiddenandunregisteredpos = @hiddenpos.unregistered 
	 @gradpos = @registeredandrecordedpos.where("admin_notes = ? OR admin_notes = ?", 'PhD', 'MS') 
	 @undergradpos = @registeredandrecordedpos.where("admin_notes = ? OR admin_notes = ?", 'BS', 'BSH') 

	 @url = record_url(:event_code => @event.event_code)

	 @individual = individual(@event) # for setting the language in the show page
end

def master_set
   @event = Event.find(params[:id]) 

end 

def master_set_input
	@event = Event.find(params[:ms][:event_id])
	@array = params[:grad_array][:years]
		@array.reject! { |c| c.empty? }
	@event.grad_array = @array
	@event.save
	@user = current_user

	redirect_to @event
end 

def default_grad

@event = Event.new(params[:event])
@master_event_id = params[:master_event_id]

@master_event = Event.find(@master_event_id)
@user = current_user
@event.event_type = 'commencement'
generate_event_code(@event)

	if @event.grad_date.blank? #didn't select a grad year to migrate
	      flash[:error] = 'Please select a graduation year/class to create a default Commencement Name Page. None was selected.'
	      redirect_to @master_event
	else 
	    if  @event.save  
	          	 #@event.customerkeys.create!(user_id: current_user.id) 
	          	 #do i want to creata customerkey? only if the user is in fact the customer?
	          	 # .customerkeys being called to (1) allow current_user to remove an admin of has a customerkey for that event page
					# so yes, create customerkey for the sake of (1); basically means that that admin created the default_grad page or sub_list
				# (2) in the owner_has_active_subscription helper
				  # ACTUALLY, NO.  This would have f'd up the helper.  Because that helper takes the first user for that event in the customer keys
				  # table, and checks to see if that user has a subscription.  Some teachers/admins will not have a subscription, so don't 
				  # want them to have an entry on the customer key table for this event. 
	    		 @event.adminkeys.create!(user_id: current_user.id)

	    		 @event.customerkeys.create(user_id: @master_event.customerkeys.first.user_id)  #needed this because couldn't find customerkey for default grad event in owner_has_active_sub
	    		 @event.adminkeys.create(user_id: @master_event.customerkeys.first.user_id) #want customer to be an admin for the default grad event, in case a teacher invited to this master page sets up the default grad event page.

	    		 default_migrate_pos(@master_event, @event)

	     		 redirect_to @event, notice: "Welcome to your name page for #{@event.title}."
	     		 
	         

	    else
	      flash.keep[:error] = 'Please enter a title and date to create a default Commencement Name Page.'
	      redirect_to @master_event
	    end
	end 

end 

#not being used
def new_sublist
	@event = Event.new(:date => Date.today, :title => "test migration#{Time.now}")
	generate_event_code(@event)
	@event.save
	
	@pos = params[:po_ids]

	@master_event = params[:migration][:e]

	@pos.each do |id|
	m = Practiceobject.find(id)
	Practiceobject.create(:event_id => @event.id, :user_id => m.user_id, :email => m.email, :first_name => m.first_name, :last_name => m.last_name, :recording => m.recording, :phonetic => m.phonetic)
	end 

	flash[:success] = "Entries were successfully migrated."
	redirect_to @event

end 

#migrate POs from master list to an existing page for this admin (current_user)
def migrate_entries
		@pos = params[:po_ids]
		@master_event_id = params[:migration][:master_event_id]
		@sub_page = params[:migration][:sub_page] #event id
		@master_event = Event.find(@master_event_id)

	if params[:migration][:sub_page].blank?
		flash[:error] = "No Name Page was selected to which to copy entries."
		redirect_to @master_event
	else
		if  @pos.blank?
					flash[:error] = "No entries were selected to copy."
					redirect_to @master_event
		else
			@sub_event = Event.find(@sub_page)

			@pos.each do |id|
			m = Practiceobject.find(id)
			Practiceobject.create(:event_id => @sub_page, :user_id => m.user_id, :email => m.email, :first_name => m.first_name, :last_name => m.last_name, :recording => m.recording, :phonetic => m.phonetic)
			end 

			flash[:success] = "Entries were successfully copied to this Name Page."
			redirect_to @sub_event
		
		end 
	
	end 

end 


#exaxct copy in events_helper
#def default_migrate_pos(master_event, sub_event) 
#	@pos = master_event.practiceobjects

#	@pos.each do |m|
#		if !m.user.grad_date.nil? && m.user.grad_date == sub_event.grad_date 
#			Practiceobject.create(:event_id => sub_event.id, :user_id => m.user_id, :email => m.email, :first_name => m.first_name, :last_name => m.last_name, :recording => m.recording, :phonetic => m.phonetic)
#	end 
#	end 

#	flash[:success] = "Entries were successfully migrated."
	
#end 

#old action - not being used
def migrate_pos
	@event = Event.new(:date => Date.today, :title => "test migration#{Time.now}")
	generate_event_code(@event)
	@event.save
	
	@pos = params[:po_ids]

	@master_event = params[:migration][:e]

	@pos.each do |id|
	m = Practiceobject.find(id)
	Practiceobject.create(:event_id => @event.id, :user_id => m.user_id, :email => m.email, :first_name => m.first_name, :last_name => m.last_name, :recording => m.recording, :phonetic => m.phonetic)
	end 

	flash[:success] = "Entries were successfully migrated."
	redirect_to @event

end 


end
