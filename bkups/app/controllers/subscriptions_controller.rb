class SubscriptionsController < ApplicationController
before_filter :signed_in_user, only: [:cancel, :unsubscribe, :index, :change_subscription, :changesubscription_choose, 
	:stripereceiver_existing, :existing_card_changesub]
before_filter :owner_or_webdev, only: [:index]

#shows the cancel subscription page
def cancel
bounce_free_account

@subs = current_user.subscriptions 

# users first (oldest) subscription, for displaying free trial information
	@firstsub = @subs.first
	@firstsub_end = @firstsub.created_at + 14.days

	if @subs && !@subs.active.blank?
	@s = @subs.active.first
	
	#@c = Stripe::Customer.retrieve(@s.customer_id)
	else #this should not happen - be careful to make sure every customer has a subscription; or at least if they have a 
		# cancel subsciption link, there is an active subscription to be canceled. 
	redirect_to current_user, notice: 'You have no active subscriptions.'
	end 
end 

#actually cancels the subscription
def unsubscribe
	@sub = Subscription.find_by_id(params[:c][:sub_id])
	@sub.update_attributes(:explanation => params[:c][:explanation], :active => false, :canceled_at => Time.now)
	#current_user.update_attributes(:customer => false)  #taken out now because a user might remain a customer if he has purchased pages
	@cust = Stripe::Customer.retrieve(current_user.customer_id)
	@cust.cancel_subscription
	redirect_to current_user, notice: "Thank you for trying our service!"
end 

def index
@subs = Subscription.all
end

def pricing
	@first_plan = Plan.find_by_my_plan_id(plan_set_one) # sets @first_plan the first plan object ACCORDING TO MY LEGEND (with my_plan_id)
	@second_plan = Plan.find_by_my_plan_id(plan_set_two)
	@third_plan = Plan.find_by_my_plan_id(plan_set_three)
	
end 

# for customers with active sub who are changing sub
def change_subscription
	bounce_free_account

	@subs = current_user.subscriptions 
	if @subs && !@subs.active.blank?
	@s = @subs.active.first
	@s_year = @s.created_at + 365.days
	#@c = Stripe::Customer.retrieve(@s.customer_id)
	else #this should not happen - be careful to make sure every customer has a subscription; or at least if they have a 
		# cancel subsciption link, there is an active subscription to be canceled. 
	redirect_to current_user, notice: 'You have no active subscriptions.'
	 # return false  is this line needed to end the action?
	end 

	# users first (oldest) subscription, for displaying free trial information
	@firstsub = @subs.first
	@firstsub_end = @firstsub.created_at + 14.days

	#@plan = Plan.find_by_name(@s.plan_id) #this would be better for easily retrieving other associated plan info;  but could have just used @s.plan_id for the plan name
	if !@s.my_plan_id.nil? # so that @plan isn't nil, which would cause problems in the view 
	@plan = Plan.find_by_my_plan_id(@s.my_plan_id)  # NOTE THAT @PLAN IS THE PLANOBJECT
				#see if active subscription has a coupon associated with it
				if !@s.coupon.nil? && Coupon.find_by_name(@s.coupon)
					@coupon = Coupon.find_by_name(@s.coupon)
					@code = @coupon.name
					@new_price = @plan.monthly_cost_cents * (100 - @coupon.percent_off)/100
				else
					@coupon = nil 
					@code = nil
					@new_price = nil 
				end 
	else
		@plan = nil
		@coupon = nil 
		@code = nil 
	    @new_price = nil 
	end 

end 

def changesubscription_choose
	@newplan = params[:sub][:newplan]  # this is an integer, corresponding to my_plan_id
	@currentplan = params[:sub][:currentplan]  #this is plans my_plan_id

    @subs = current_user.subscriptions 
	# users first (oldest) subscription, for displaying free trial information
	@firstsub = @subs.first
	@firstsub_end = @firstsub.created_at + 14.days

	if !current_user.customer_id.blank?
	 c = Stripe::Customer.retrieve(current_user.customer_id)
	 @last4 = c.active_card.last4
	 @cardtype = c.active_card.type
	end 
 
	if @newplan == @currentplan  #CAN CHANGE THIS TO COMPARE NAMES INSTEAD OF MYPLANID TO PREVENT CHANGING TO A CHEAPER 'GOLD' SUB
		flash[:error] = "You are already subscribed to the #{Plan.find_by_my_plan_id(@currentplan).name.titleize} plan."
		redirect_to change_subscription_path
		#LEARNING NOTE:  had @nplan outside of this if-else-end, so Rails was executing the external code even though we made a redirect_call here.  IT DOES THAT. So if want to end the action, should have called return false
	else
	@nplan = Plan.find_by_my_plan_id(@newplan)
	@cplan = Plan.find_by_my_plan_id(@currentplan)
	# NEED TO CALCULATE THIS HERE, MAYBE USE A HELPER
	@new_events_number = adjust_number(@nplan.events_number, @cplan.events_number)
	@when_eligible = wheneligible(@nplan.events_number, @cplan.events_number)

		 #see if active subscription has a coupon associated with it
			if @subs && !@subs.active.blank?
			@s = @subs.active.first
				if !@s.coupon.nil? && Coupon.find_by_name(@s.coupon)
					@coupon = Coupon.find_by_name(@s.coupon)
					@code = @coupon.name
					@new_price = @nplan.monthly_cost_cents * (100 - @coupon.percent_off)/100
				else
					@coupon = nil 
					@code = nil
					@new_price = nil 
				end 
			end 
	end 





end

#incoming from changesubscription_choose for new cc info; should only apply when someone has an active sub
def stripereceiver_existing
	token = params[:stripeToken]
	@newplan = params[:plan] #this is an integer, corresponding to my_plan_id
	@new_events_number = params[:new_events_number] #this should be the adjusted number as calculated changesubscription_choose
	@code = params[:code]
	@new_price = params[:new_price]

	
	c = Stripe::Customer.retrieve(current_user.customer_id)
	
	if update_card_and_subscription(token, @newplan) #helper method in users_helper
			#cancel current active subscription in my database
		    @subs = current_user.subscriptions 
			if @subs && !@subs.active.blank?
			@s = @subs.active.first
			@s.update_attributes(:active => false, :canceled_at => Time.now)
			end

			#create new subscription object in my database
			@sub = Subscription.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id, 
				:my_plan_id => @newplan, :plan_name => Plan.find_by_my_plan_id(@newplan).name,:active => true)
		    @sub.events_remaining = @new_events_number
		    @sub.coupon = @code 
		    @sub.save 

		    #create receipt
		    @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id,
		    	:subscription_id => @sub.id, :sub_my_plan_id => @sub.my_plan_id, :sub_plan_name => @sub.plan_name,
		    	:sub_events_number => @sub.events_remaining, :sub_reg_monthly_cost_in_cents => Plan.find_by_my_plan_id(@sub.my_plan_id).monthly_cost_cents,
		    	:sub_actual_monthly_cost_in_cents => @new_price, :sub_coupon_name => @sub.coupon) 
		    @r.save

			flash[:success] = "Your credit card details have been updated, and your subscription has now changed to the #{Plan.find_by_my_plan_id(@newplan).name.titleize} plan!"
			redirect_to current_user
	else  #probably an error in processing the new card details, e.g. an invalid card

			 # getting error for change_subscriptio rendering b/c @plan was nil, so change to a redirect and changed to flash instead of flash.now in the helper method
			redirect_to change_subscription_path
	end 
    

end

#incoming from changesubscription_choose when stays with existing cc info
def existing_card_changesub
	@newplan = params[:newsub][:newplan]  # this is an integer, corresponding to MY PLAN ID
	@new_events_number = params[:newsub][:new_events_number] #this should be the adjusted number as calculated changesubscription_choose
	@nplan = Plan.find_by_my_plan_id(@newplan)
	@code = params[:newsub][:code]
	@new_price = params[:newsub][:new_price]

	# no need to use the stripe-rescue helper methods here because not trying a new card. still, can conditionalize the actions here on stripe successfully updating

	if !current_user.customer_id.blank?
	 c = Stripe::Customer.retrieve(current_user.customer_id)
	end 
	#what if not already a customer? i.e., just a user?  must already be a stripe customer if has a card on file, and because this is downstream from 'change sub' which means user HAS an active SUB!
	
	#updates subscription plan in stripe
	if c.update_subscription(:plan => @newplan, :prorate => true)

		#cancel current active subscription in my database
	    @subs = current_user.subscriptions 
		if @subs && !@subs.active.blank?
		@s = @subs.active.first
		@s.update_attributes(:active => false, :canceled_at => Time.now)
		end

		#create new subscription object in my database
		@sub = Subscription.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id, :my_plan_id => @newplan, :plan_name => Plan.find_by_my_plan_id(@newplan).name, :active => true)
	    @sub.events_remaining = @new_events_number
	    @sub.coupon = @code 
	    @sub.save 

	    #create receipt
	    @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id,
	    	:subscription_id => @sub.id, :sub_my_plan_id => @sub.my_plan_id, :sub_plan_name => @sub.plan_name,
	    	:sub_events_number => @sub.events_remaining, :sub_reg_monthly_cost_in_cents => Plan.find_by_my_plan_id(@sub.my_plan_id).monthly_cost_cents,
	    	:sub_actual_monthly_cost_in_cents => @new_price, :sub_coupon_name => @sub.coupon) 
	    @r.save

		flash[:success] = "Your subscription has now changed to the #{Plan.find_by_my_plan_id(@newplan).name.titleize} plan!"
		redirect_to current_user

	else  #this shouldn't happen - don't know why Stripe wouldn't properly update the subscription
		flash[:error] = "Something went wrong. Please try again or contact NameCoach customer service."
		redirect_to change_subscription_path
	end 

end 


end
