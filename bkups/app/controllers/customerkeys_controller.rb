class CustomerkeysController < ApplicationController
before_filter :signed_in_user
before_filter :owner, only: [:index]

	def index 
		@keys = Customerkey.all
	end

end
