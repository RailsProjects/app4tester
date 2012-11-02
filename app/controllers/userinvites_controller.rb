class UserinvitesController < ApplicationController
before_filter :owner, only: [:index]

	def index
		@uis = Userinvite.all
	end

	#this action is called when admin sends a reminder to signup
	def create
		 @po = Practiceobject.find_by_id(params[:userinvite][:practiceobject_id])
		 #find the associated practice object from the incoming :userinvite object
		 @userinvite = Userinvite.new(practiceobject_id: @po.id, recipient_email: @po.email, admin_id: current_user.id)
		 #create an altogeher new :userinvite object, setting it's practiceobject_id to the id of that practiceobject
		 # @userinvite.sent_at is updated in the Mailer action
	     @userinvite.save  
	     startx
	     UserInviteMailer.invite_reminder(@userinvite, new_user_url(:token => @po.token), @po, @bcc).deliver 
	     redirect_to @userinvite.practiceobject.event, notice: 'Reminder email sent.'
	end

	#this action is called when admin sends a reminds to record (for a signed-up user)
    def reminder
    	 @po = Practiceobject.find_by_id(params[:po][:x])
		 #find the associated practice object from the incoming practice object id hidden field (f.id)
		 @userinvite = Userinvite.new(practiceobject_id: @po.id, recipient_email: @po.email, admin_id: current_user.id)
		 #create an altogeher new :userinvite object, setting it's practiceobject_id to the id of that practiceobject
	     @userinvite.save  
	     UserInviteMailer.recording_reminder(@userinvite, root_url, @po).deliver 
	     redirect_to @userinvite.practiceobject.event, notice: 'Reminder email (to record name) sent.'

	end 

	#this action is called when admin asks the user to re-record
	def rerecord
    	 @po = Practiceobject.find_by_id(params[:po][:x])
		 #find the associated practice object from the incoming practice object id hidden field (f.id)
		 @userinvite = Userinvite.new(practiceobject_id: @po.id, recipient_email: @po.email, admin_id: current_user.id)
		 #create an altogeher new :userinvite object, setting it's practiceobject_id to the id of that practiceobject
	     @userinvite.save  
	     UserInviteMailer.rerecording_reminder(@userinvite, root_url, @po).deliver 
	     redirect_to @userinvite.practiceobject.event, notice: 'Reminder email (to rerecord name) sent.'

	end 

end
