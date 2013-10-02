class Voicegem < ActiveRecord::Base
  attr_accessible :admin_id, :admin_notes, :email, :event_id, :first_name, :hidden, :last_name, :length, :notes, :recording, :request, :token, :user_id, :vg_userinvite_id

  belongs_to :event 
  belongs_to :user 

  has_many :vg_userinvites 

  before_save { self.email.downcase! }
  before_save { self.email.strip!}
  before_save :polish_names

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true, 
                    length: { maximum: 254 }, 
                    format:     { with: VALID_EMAIL_REGEX }


    validates :first_name,  length: { maximum: 254 }
    validates :last_name,  length: { maximum: 254 }
    validates :token,  length: { maximum: 254 }
    validates :recording,  length: { maximum: 254 }
    validates :request,  length: { maximum: 254 }
    
   before_create :generate_token



   scope :registered, where('user_id is not NULL')
   scope :unregistered, where('user_id is NULL')
   scope :recorded, where('recording is not NULL')
   scope :unrecorded, where('recording is NULL')
   scope :hidden, where(:hidden => true)
   scope :visible, where("hidden is NULL OR hidden = ?", false)
   default_scope order(:last_name)



 def polish_names
  if !self.first_name.blank?
    self.first_name.strip! 
    self.first_name[0] = self.first_name[0].upcase
  end 
  if !self.last_name.blank?
    self.last_name.strip! 
    self.last_name[0] = self.last_name[0].upcase
  end 
end 

  def generate_token 
    #if self.token.blank?  --thought i might need this to keep PO tokens unchanging, for the sake of reminder emails - but this is not an issue
    # because once the user registers (and token changes), reminder to register is not available, and the reminder to rerecord just directs to sign in
    # UPDATE: this is an issue now b/c admin can re-save the PO by editing admin_notes. solution1 is this conditnoal.  solution 2 is change it to 
    # before_create?
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end



end
