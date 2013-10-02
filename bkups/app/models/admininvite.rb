class Admininvite < ActiveRecord::Base
  attr_accessible :event_id, :token, :recipient_email, :first_name, :last_name, :admin_id, :user_id 

  belongs_to :event 


  before_save { self.recipient_email.downcase! }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :recipient_email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX }


    validates :token,  length: { maximum: 254 }
    validates :first_name,  length: { maximum: 254 }
    validates :last_name,  length: { maximum: 254 }
    validates :recipient_email,  length: { maximum: 254 }

   before_save :generate_token



private 
  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
