class VgUserinvite < ActiveRecord::Base
  attr_accessible :admin_id, :invite_type, :recipient_email, :sent_at, :voicegem_id

  belongs_to :voicegem

  validates :recipient_email,  length: { maximum: 254 }
  validates :invite_type,  length: { maximum: 254 }
  
end
