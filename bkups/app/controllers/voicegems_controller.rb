class VoicegemsController < ApplicationController
before_filter :vgfilter, only: [:index]
before_filter :signed_in_user, only: [:index, :show, :new, :edit, :create, :update, :destroy]
before_filter :owner, only: [:index, :show, :new, :create]
before_filter :correct_user_for_vg, only: [:edit] 


def vgrecord

  if signed_in?
    flash[:success] = "Trying to record your VoiceGem? Please do so below."
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

def vg_event_link_create

    @user = User.new
    @user.email = params[:user][:email]
    @pw = SecureRandom.urlsafe_base64
    @user.password=@pw
    @user.password_confirmation=@pw
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.vg_notes = params[:user][:vg_notes]
    @user.vg_request = params[:user][:vg_request]
    @user.event_code = params[:user][:event_code]
    @event_code = params[:user][:event_code]
          #moved this up here so that what user entered is left in tact when re-renders form, and can take out @user = User.new below 

  if !params[:user][:event_code].blank? #see if any code parameter is passed incoming from the form - don't want to run this code if not, i.e., if user is signing up                from an inviation token
      if Event.find_by_event_code(params[:user][:event_code].upcase.delete(' ')) # see if the code entered is even a code for any event - params[:code] is coming in from the form
                            #but how to get code in from the form?    
        @event  = Event.find_by_event_code(params[:user][:event_code].upcase.delete(' '))
        #run code to sign up user for this event, first to try to save the user (validate his info)
        
              if @user.save
                  UserMailer.vg_welcome(@user).deliver
                  sign_in @user
                  # try to give user a PO for this event
                    # first check to see if an existing PO with this email for this event, and leave the other events/PO's alone; if floating  # PO's with this email for other events, will be caught by the sign-up level checks - user can just sign in then to anchor 
                    # themselves to that PO/event

                    @vg = Voicegem.new(:user_id => @user.id, :event_id => @event.id, :email => @user.email, :first_name => @user.first_name, :last_name => @user.last_name, :notes => @user.vg_notes, :request => @user.vg_request)
                    if @vg.save  #should be fine - since this is a new user, there can't be a PO for this event with his ID - true, but            #still problem if ADMIN ALSO INVITED AT THAT EMAIL ADDRESS, THEREBY CREATING A PO, AND USER HASN'T            #REGISTERED YET
                            # flash[:info] = "Now just record your VoiceGem for this event (#{@event.title}), and you're done!"
                             redirect_to vgrecord_step2_path(:user => @user, :vg => @vg, :event => @event, :event_code => @event_code)
                    else #already a PO for this user_id and event, but this shouldn't happen since it's a new user
                      redirect_to @user, notice: "Thanks for registering. However, something may have gone wrong - please contact NameCoach for support."
                    end 

                  

              else # user already exists, or otherwise didn't validate as user
                    #redirect back to this sign-up form - should render errors; if it's because ther user already exists, this is covered by the 
                    # sign-in form on form, but maybe good to check first and tell user to sign-in.  Notice: "If you have already registered, please sign in under 'Already Registered.'""
                      if  User.find_by_email(@user.email)#if the user already exists, tell them to try logging in to the right
                              if signed_in? #perhaps pressing back button from record_step2 to change name or email?
                                      #users may never get here because we check signed_in? in the record action
                                      if !@user.recording.blank? #has already recorded.  Just take them to their profile page
                                        flash[:error] = "If you wish to update your VoiceGem or anything else, please do so on this page."
                                        redirect_to current_user  
                                     else #has not recorded - so take them to the recording page (record_step2) again
                                      flash[:error] = "Please record your VoiceGem. If you wish to edit your name/email or notes to the MC/DJ, do so on your profile page after you record your name."
                                      @vg = current_user.voicegems.find_by_event_id(@event.id).first
                                      redirect_to vgrecord_step2_path(:user => @user, :event => @event, :event_code => @event_code, :vg => @vg)
                                      end 
                              else #probably trying to register from record page with an existing email
                                    flash[:error] = "This email (#{@user.email}) is already registered on our site. Please sign in under 'Already Registered?' (below) to record a VoiceGem for this event. If you didn't set or forgot your password, please click 'Reset Password' above."
                                      redirect_to vgrecord_path(:event_code => @event_code) 
                              end 
                      else
                         flash[:error] = "Please be sure to enter your first name, last name, and valid email address."         
                          redirect_to vgrecord_path(:event_code => @event_code) 
                      end 
                                          
              end   
      else #code entered doesn't exist for any event
        #@user = User.new #for the re-rendering of the eventcodesignup view
        #render this action again, with the flash message
        flash[:error] = 'Something went wrong. Please contact NameCoach for support'
        redirect_to vgrecord_path(:event_code => @event_code)  
      end 
  else
    #@user = User.new #for the re-redering of the eventcodesignup view
    #run existing users#create code - maybe make this a helper method
    # or make this whole code a separate controller action, and just redirect to the form saying no code was entered
    flash[:error] = 'Something went wrong.  Please contact NameCoach for support.'
    redirect_to vgrecord_path(:event_code => @event_code)  
    
    
  end


end 


def vgrecord_step2
  @event = Event.find(params[:event])
  @event_code = params[:event_code]
  @vg = params[:vg]

  flash.keep
  @user = current_user
#  @user = current_user this can't be being set if just rendering this page 
#@vg and @user must be being set in the vg_event_link_create action (which mediates vgrecord and vgrecord_step2)
end 


def vgtest
  @vg = Voicegem.find(params[:id])
  render :layout => nil
  # necessary b/c having the rendered header was causing problems on the test page
end 

def vgsaveupload

      @vg = Voicegem.find_by_id(params[:x])
      @time = Digest::SHA1.hexdigest([Time.now, rand].join)[4..8].upcase.to_s

      directory = "app/assets/images"
      # create the file path
      path = File.join(directory, current_user.id.to_s)
      path+= '_'
      path+= @vg.id.to_s
      path+= '_'
      path+= @time
      path+='.wav'
     # write the file to local images directory
      File.open(path, "wb") { |f| f.write(request.body.read) }

      #upload to S3
       bucket_name = ENV['VG_BUCKET_NAME']
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
                      :input => "s3://#{ENV['VG_BUCKET_NAME']}/#{current_user.id.to_s}_#{@vg.id.to_s}_#{@time}.wav",
                      :outputs => [
                        {
                          :url => "s3://#{ENV['VG_BUCKET_NAME']}/#{current_user.id.to_s}_#{@vg.id.to_s}_#{@time}.mp3",
                          :audio_codec => "mp3",
                          :public => 1,

                          }]

                          })


    @vg.update_attributes(recording: "#{current_user.id.to_s}_#{@vg.id.to_s}_#{@time}")
    current_user.update_attributes(recording: "#{current_user.id.to_s}_#{@vg.id.to_s}_#{@time}")

      false 

  end

  def demo_record_vg
     @event = Event.find(ENV['demopage'].to_i)
    
     @event_code = @event.event_code
    
     @vg = Voicegem.new

      flash.keep
     @user = User.new
  end 



  def vg_event_code_add
      user = User.find_by_email(params[:session][:email].downcase.strip)
      @event_code = params[:session][:event_code]

     if user && user.authenticate(params[:session][:password]) then
        sign_in user
        if Event.find_by_event_code(@event_code.upcase.delete(' '))  #find event
             @event  = Event.find_by_event_code(@event_code.upcase.delete(' '))
             addvoicegem(user)
             redirect_to user, notice: "Thank you for registering as an attendee for #{@event.title}.  Please make sure to create or update your VoiceGem for this event."

        else #do we need an else statement in case can't find the PO by token?
          redirect_to user, notice: "There was an error. Please sign out and try again, or contact NameCoach for support."
        end  
   
    else #invalid email/pw
      @user = User.new 
      @event = Event.find_by_event_code(@event_code.upcase.delete(' '))
      flash.now[:error] = 'Invalid email/password combination'
      render action: 'vgrecord'
    # Creates an error message and re-render the signin form.

     end


  end 

  def voicegems_info
     @event = Event.find(ENV['demopage'].to_i)
     @event_code = @event.event_code
     @url = demo_record_vg_url(:event_code => @event.event_code)
  end 

  def index
    @voicegems = Voicegem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @voicegems }
    end
  end

  # GET /voicegems/1
  # GET /voicegems/1.json
  def show
    @voicegem = Voicegem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @voicegem }
    end
  end

  # GET /voicegems/new
  # GET /voicegems/new.json
  # NOT USING THIS ACTION
  def new
    @voicegem = Voicegem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @voicegem }
    end
  end

  # GET /voicegems/1/edit
  def edit
    @voicegem = Voicegem.find(params[:id])
    @vg = Voicegem.find(params[:id]) # need this to pass in right voicegem id into vgsaveupload via vgtest render
  end

  # POST /voicegems
  # POST /voicegems.json
  # NOT USING THIS ACTION
  def create
    @voicegem = Voicegem.new(params[:voicegem])

    respond_to do |format|
      if @voicegem.save
        format.html { redirect_to @voicegem, notice: 'Voicegem was successfully created.' }
        format.json { render json: @voicegem, status: :created, location: @voicegem }
      else
        format.html { render action: "new" }
        format.json { render json: @voicegem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /voicegems/1
  # PUT /voicegems/1.json
  def update
    @voicegem = Voicegem.find(params[:id])

      if @voicegem.update_attributes(params[:voicegem])
        flash[:info] = 'Your VoiceGem was updated.  If you recorded a new VoiceGem, please wait a minute and refresh the page to see it take effect.' 
        redirect_to current_user 
       
      else
         render action: "edit" 
       
      end
  end




  def vg_unhide
    @vg = Voicegem.find(params[:vg][:vg_id])

     if @vg.update_attributes(:hidden => false)  #we're relying on fact that this is what hitting the unhide actin is supposed to do
        redirect_to @vg.event, notice: 'Entry has been restored.' 
       
    else
         redirect_to @vg.event, notice: 'We encountered an error.' 
       
      end

  end 



  # DELETE /voicegems/1
  # DELETE /voicegems/1.json
 def destroy
    @voicegem = Voicegem.find(params[:id])
    @voicegem.update_attributes(hidden: true)

    respond_to do |format|
      format.html { redirect_to @voicegem.event }
      format.json { head :no_content }
    end
  end
end
