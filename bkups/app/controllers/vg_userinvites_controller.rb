class VgUserinvitesController < ApplicationController

	def vg_rerecord
		@vg = Voicegem.find_by_id(params[:vg][:x])
		@vg_userinvite = VgUserinvite.new(voicegem_id: @vg.id, recipient_email: @vg.email, admin_id: current_user.id)
		@vg_userinvite.save  
	    @to = @vg.user.email
	    startx
	    UserInviteMailer.vg_rerecording_reminder(@vg_userinvite, root_url, @vg, @to).deliver 
	    redirect_to @vg_userinvite.voicegem.event, notice: 'Request to re-record sent.'
	end 


end
