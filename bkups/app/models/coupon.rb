class Coupon < ActiveRecord::Base
  attr_accessible :active, :duration, :duration_in_months, :free_page_name, :free_page_user, :max_redemptions, :name, :percent_off, :redeem_by, :times_redeemed, :cost
end
