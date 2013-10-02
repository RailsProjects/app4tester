class AdminkeysController < ApplicationController
before_filter :signed_in_user
before_filter :owner, only: [:index, :destroy]


	def index 
		@keys = Adminkey.all
	end

    #not being used - using removeadmin instead
	def destroy
    @key = Adminkey.find(params[:id])
    @key.destroy

 	redirect_to adminkeys_url 

    end

    def removeadmin
    	@event = Event.find(params[:a][:event_id])
    	@adminkey = @event.adminkeys.find_by_user_id(params[:a][:a_id])
    	@event = Event.find(params[:a][:event_id])
    	@u = User.find(params[:a][:a_id])
    	@adminkey.destroy
    	
    	redirect_to @event, notice: "#{@u.email} is no longer an admin for this event."
    end 


end
