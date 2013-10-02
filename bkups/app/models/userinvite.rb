class Userinvite < ActiveRecord::Base
  attr_accessible :admin_id, :practiceobject_id, :recipient_email, :sent_at, :invite_type

  belongs_to :practiceobject 

  validates :recipient_email,  length: { maximum: 254 }
  validates :invite_type,  length: { maximum: 254 }

end
