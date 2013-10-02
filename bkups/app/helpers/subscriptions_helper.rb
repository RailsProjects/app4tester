module SubscriptionsHelper

# wasn't sure how to make this work
#def suboptions
#	if @plan.name == 'basic'
#		[ ["Gold Plan (50 pages/yr, $55/mo)", "gold"], ["Pro Plan (100 pages/yr, $85/mo)", "pro"] ]
#	end
#	if @plan.name == 'gold'
#		[["Basic Plan (25 pages/yr, $35/mo)", "basic"], ["Pro Plan (100 pages/yr, $85/mo)", "pro"] ]
#	end
#
#	[["Basic Plan (25 pages/yr, $35/mo)", "basic"], ["Gold Plan (50 pages/yr, $55/mo)", "gold"], ["Pro Plan (100 pages/yr, $85/mo)", "pro"] ]
#end 
#def options
#["Silver Plan (25 pages/yr, $35/mo)", 1], ["Gold Plan (50 pages/yr, $55/mo)", 1], ["Platinum Plan (100 pages/yr, $85/mo)", 3]
#      option = '['
 #     option+= '"Silver Plan"'
 ##     option+= '1'
 #     option+= ']'
#end

def adjust_number(newplannumber, oldplannumber)
	@subs = current_user.subscriptions 
	if @subs && !@subs.active.blank?
	@s = @subs.active.first
	end

	@duration = ((Time.now - @s.created_at) / 1.day).round.to_f  #needed to_float instead of to_integer because dividing 5/15, e.g., resulted in 0
	@proportion = @duration/365
	@should_have_used = (@proportion*oldplannumber).round
	@diff = @should_have_used - @s.events_used
	newplannumber + @diff
	# ACCOUNT FOR CASE IN WHICH THIS RETURNS zero or less; done in the the changesubscription_choose view; in this case, calls wheneligible helper below.

end 

def wheneligible(newplannumber, oldplannumber)
	@subs = current_user.subscriptions 
	if @subs && !@subs.active.blank?
	@s = @subs.active.first
	end

	 #1.day*(365*((0 - newplannumber + @s.events_used)/oldplannumber)) + @s.created_at 
	 n = ((0 - newplannumber + @s.events_used).to_f)/oldplannumber 
	 x = (365*n).to_i
	 @s.created_at + x.days

end

end
