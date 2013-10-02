class StaticController < ApplicationController

def value
end 

def works
end 

def plantest
end

def terms
end

def cartest
end 

def weddings

#   @first_plan = Plan.find_by_my_plan_id(plan_set_one) # sets @first_plan the first plan object ACCORDING TO MY LEGEND (with my_plan_id)
#   @second_plan = Plan.find_by_my_plan_id(plan_set_two)
#   @third_plan = Plan.find_by_my_plan_id(plan_set_three)
  @event = Event.find(ENV['demopage'].to_i)
  @first_plan = Plan.find_by_my_plan_id(plan_set_one) # sets @first_plan the first plan object ACCORDING TO MY LEGEND (with my_plan_id)
  @second_plan = Plan.find_by_my_plan_id(plan_set_two)
  @third_plan = Plan.find_by_my_plan_id(plan_set_three)
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

def receptions
  @event = Event.find(ENV['demopage'].to_i)
  @first_plan = Plan.find_by_my_plan_id(plan_set_one) # sets @first_plan the first plan object ACCORDING TO MY LEGEND (with my_plan_id)
  @second_plan = Plan.find_by_my_plan_id(plan_set_two)
  @third_plan = Plan.find_by_my_plan_id(plan_set_three)
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

def commencements
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

  @url = demo_record_url(:event_code => @event.event_code)

end 

def students
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

# FOR TESTING LAYOUT
def students_extra 
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

def students_naesp
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

def students_naspa
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



def privacy
end 

def faq
end 

def graduations
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

def macfaq
end

def flashtest
  render :layout => nil
end 

def support_test
  #render :layout => nil
end 

def macbeathtestimonial
  #render :layout => nil
end 

def search_test
end

def flashdetect
 # render :layout => nil
end 

def precord
 # if params[:ZenId]
  #@ZenId = params[:ZenId]
 # else
 # @ZenId = 4 
 # end  
  @practiceobject = current_user.practiceobjects.first
end

def irecord
render :layout => nil
end 

def isave

      directory = "app/assets/images"
      # create the file path
      path = File.join(directory, current_user.id.to_s)
      path+='.mov'
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
                      :input => "s3://#{ENV['BUCKET_NAME']}/#{current_user.id.to_s}.mov",
                      :outputs => [
                        {
                          :url => "s3://#{ENV['BUCKET_NAME']}/#{current_user.id.to_s}.mp3",
                          :audio_codec => "mp3",
                          :skip_video => true,
                          :public => 1,

                          }]

                          })

#{
 # "input": "s3://zencoder-customer-ingest/uploads/2013-07-24/71268/58113/4c797080-f434-11e2-8421-47a170fadea2.mov",
 # "output": [
 #   {
 #     "skip_video": true,
 #     "audio_codec": "mp3"
 ## ]
#}

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

      redirect_to current_user

  end



end