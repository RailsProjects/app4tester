class Practiceobject < ActiveRecord::Base
  attr_accessible :admin_id, :admin_notes, :email, :event_id, :first_name, :last_name, :token, :user_id, :userinvite_id, :recording, :phonetic, :notes, :hidden, :rec, :vidrec

  

  belongs_to :event 
  belongs_to :user 

  has_many :userinvites 

  mount_uploader :vidrec, VidrecUploader

  before_save { self.email.downcase! }
  before_save { self.email.strip!}
  before_save :polish_names


  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true, 
                    length: { maximum: 254 }, 
                    format:     { with: VALID_EMAIL_REGEX }


 validates :event_id, :uniqueness => {:scope => :user_id}, :unless => "user_id.nil?"
# this is to prevent a user from having multiple practiceobjects for the same event - that admin_id/user_id combo can only exist once in the practiceobject table
# need to have :event_id first, because PO's don't start out with USER ID'S!  Actually, what fixed this is the conditional validation
# but now it seems to be taking forever to invite an attendee!!!!! see if can fix this...

    validates :first_name,  length: { maximum: 254 }
    validates :last_name,  length: { maximum: 254 }
    validates :token,  length: { maximum: 254 }
    validates :recording,  length: { maximum: 254 }
    validates :phonetic,  length: { maximum: 254 }
    
   before_create :generate_token

   scope :registered, where('user_id is not NULL')
   scope :unregistered, where('user_id is NULL')
   scope :recorded, where('recording is not NULL')
   scope :unrecorded, where('recording is NULL')
   scope :hidden, where(:hidden => true)
   scope :visible, where("hidden is NULL OR hidden = ?", false)
   default_scope order(:last_name)

   # see http://stackoverflow.com/questions/4351037/rails-3-plugin-scope-out-doesnt-work

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
# note that !self.first_name.nil? was still saying not method error on nil (self.first_name) for upcase - why is this?


private 
  def generate_token 
    #if self.token.blank?  --thought i might need this to keep PO tokens unchanging, for the sake of reminder emails - but this is not an issue
    # because once the user registers (and token changes), reminder to register is not available, and the reminder to rerecord just directs to sign in
    # UPDATE: this is an issue now b/c admin can re-save the PO by editing admin_notes. solution1 is this conditnoal.  solution 2 is change it to 
    # before_create?
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

               
end
