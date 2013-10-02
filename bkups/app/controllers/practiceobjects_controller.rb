class PracticeobjectsController < ApplicationController
  # GET /practiceobjects
  # GET /practiceobjects.json
  before_filter :signed_in_user
  before_filter :owner, only: [:index, :show]
  # destroy action modified to just hide the PO

  before_filter :correct_user_for_po, only: [:edit] 

  def index
    @practiceobjects = Practiceobject.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @practiceobjects }
    end
  end

  # GET /practiceobjects/1
  # GET /practiceobjects/1.json
  def show
    @practiceobject = Practiceobject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @practiceobject }
    end
  end

  # GET /practiceobjects/new
  # GET /practiceobjects/new.json
  def new
    @practiceobject = Practiceobject.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @practiceobject }
    end
  end

  # GET /practiceobjects/1/edit
  def edit
    @practiceobject = Practiceobject.find(params[:id])
  end

  # POST /practiceobjects
  # POST /practiceobjects.json

  #this action includes the admin's first invitation to the user; it's in PO controller b/c when user is first invited, a PO is created
def create
    @practiceobject = Practiceobject.new(params[:practiceobject]) #this sets the event_id attribute through a hidden field 
    @practiceobject.admin_id = current_user.id
    @event = @practiceobject.event
    if User.find_by_email(@practiceobject.email) #check to see if entered email belongs to an existing user - if does..
             u = User.find_by_email(@practiceobject.email)
            if @event.practiceobjects.find_by_user_id(u.id) #check to see if existing user has a PO FOR THIS EVENT - if does, tell admin that attendee already registered for this event
               redirect_to @event, notice: 'Attendee with that email address is already registered for this event.'
            else # existing user does not have a PO for this event, create one for him for this event, send email that been registered for another event
                  @practiceobject.user_id = u.id
                  @practiceobject.recording = u.recording #in case the existing user already has a recording, this will be the default for this practice object
                  @practiceobject.notes = u.notes #default to user attribute
                  @practiceobject.phonetic = u.phonetic # default to user attribute
                  if @practiceobject.save
                       @ui = @practiceobject.userinvites.create!
                       @ui.admin_id = current_user.id
                       @ui.recipient_email = @practiceobject.email 
                       @ui.invite_type = "invitation"
                       @ui.save
                       @to = @practiceobject.user.email
                       if Rails.env.staging?
                         startx
                       end
                       UserInviteMailer.existing_user_invitation(@ui, root_url, @practiceobject, @to).deliver 
                       redirect_to @event, notice: 'Attendee with that email address is an existing user and is now registered for this event.'
                       copy_to_master(@practiceobject, @practiceobject.event)
                    else
                      flash[:error] = 'Please enter a valid email address.'
                      redirect_to @event
                    end 
            end  
    else #email does not belong to an existing user
            if @event.practiceobjects.find_by_email(@practiceobject.email)  
               # check to see if invitation already sent to that email FOR THIS EVENT - i.e., if there's an existing PO with that email address (for an unregisetered user)
               # if so, notifiy admin that attendee already invited for this event
                   redirect_to @event, notice: 'Attendee with that email address has already been invited. Please see record in the Unregistered Attendees tab, from which you can send  a reminder email.'
            else #invitation not sent to that email, execute original code to invite new user as an attendee
                    if @practiceobject.save
                       @ui = @practiceobject.userinvites.create!
                       @ui.admin_id = current_user.id
                       @ui.recipient_email = @practiceobject.email 
                       @ui.invite_type = "invitation"
                       @ui.save
                        # for exceptions to staging mail interceptor
                       @to = @practiceobject.email
                       if Rails.env.staging?
                         startx
                       end
                       UserInviteMailer.user_invitation(@ui, new_user_url(:token => @practiceobject.token), @practiceobject, @to).deliver 
                       flash[:success] = "An invitation was emailed to #{@practiceobject.email}. The record should appear in the third tab."
                       redirect_to @event
                    else
                      flash[:error] = 'Please enter a valid email address.'
                      redirect_to @event
                    end 

            end
    end 

end




def porecording
  @po = Practiceobject.find(params[:id])
  render :layout => nil
  # necessary b/c having the rendered header was causing problems on the test page
end      



def posaveupload
      @po = Practiceobject.find_by_id(params[:x])
           
      directory = "app/assets/images"

      # create the file path
      path = File.join(directory, current_user.id.to_s)
      path+= '_'
      path+= @po.id.to_s
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
                      :input => "s3://#{ENV['BUCKET_NAME']}/#{current_user.id.to_s}_#{@po.id.to_s}.wav",
                      :outputs => [
                        {
                          :url => "s3://#{ENV['BUCKET_NAME']}/#{current_user.id.to_s}_#{@po.id.to_s}.mp3",
                          :audio_codec => "mp3",
                          :public => 1,

                          }]

                          })


        #update recording path for this PO
        @po.update_attributes(recording: "#{current_user.id.to_s}_#{@po.id.to_s}")

        if current_user.recording.blank?  #set user recording path to this first PO that's recorded
          # this doesn't do much because will apply when user has more than one PO but hasn't recorded anything yet,
          # so the current_user.recording won't be used anywhere on the show pages
          current_user.update_attributes(recording: "#{current_user.id.to_s}_#{@po.id.to_s}")
        end 

        #set any other PO's with no recording paths to this first recording (this PO's path), through the current_user.recording
             current_user.practiceobjects.each do |x|
              if x.recording.blank?
                 x.update_attributes(recording: current_user.recording)
              end 
             end    

        false 
          
  end




  # PUT /practiceobjects/1
  # PUT /practiceobjects/1.json
  def update
    @practiceobject = Practiceobject.find(params[:id])

   
      if @practiceobject.update_attributes(params[:practiceobject])
        redirect_to precord_path(:ZenId => @ZenId), notice: 'Your NameGuide was updated.' 
       
      else
         render action: "edit" 
       
      end
   
  end

  def unhide
    @practiceobject = Practiceobject.find(params[:po][:po_id])

     if @practiceobject.update_attributes(:hidden => false)  #we're relying on fact that this is what hitting the unhide actin is supposed to do
        redirect_to @practiceobject.event, notice: 'Entry has been restored.' 
       
    else
         redirect_to @practiceobject.event, notice: 'We encountered an error.' 
       
      end

  end 

  # DELETE /practiceobjects/1
  # DELETE /practiceobjects/1.json
  def destroy
    @practiceobject = Practiceobject.find(params[:id])
    @practiceobject.update_attributes(hidden: true)

    respond_to do |format|
      format.html { redirect_to @practiceobject.event }
      format.json { head :no_content }
    end
  end
end
