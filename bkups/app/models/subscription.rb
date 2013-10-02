class Subscription < ActiveRecord::Base
  attr_accessible :active, :canceled_at, :customer_id, :email, :plan_id, :user_id, :explanation, :my_plan_id, :plan_name, :unlimited

  belongs_to :user

  validates :email,  length: { maximum: 254 }
  validates :plan_id,  length: { maximum: 254 }
  validates :customer_id,  length: { maximum: 254 }

  scope :active, where(active: true)

  default_scope order: 'subscriptions.created_at ASC'  #puts in order from oldest (first) to newest

end
