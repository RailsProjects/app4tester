class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :notes, :phonetic, :recording, :salt, :password_confirmation, :password, :admin, :customer, :invite_token, :event_code, :customer_id, :company, :password_reset_token, :event_type, :subscription_id
  #be sure to remove admin and customer from accessible, which I think then means you can't submit a form, but rather have to set it in a controller?
  attr_accessor :password_confirmation, :event_code, :access_code 

  has_secure_password

  has_many :customerkeys
  has_many :customerevents, through: :customerkeys, source: :event

  has_many :adminkeys
  has_many :adminevents, through: :adminkeys, source: :event

  has_many :practiceobjects
  has_many :practiceevents, through: :practiceobjects, source: :event

  has_many :subscriptions
  #change this to has_one?  NO - want to allow a user to create many subscriptions, just one that's active at a time

  has_many :voicegems
  has_many :vgevents, through: :voicegems, source: :event

  before_save { self.email.downcase! }
  before_save { self.email.strip!}
  before_save :polish_names
  before_save :update_PO
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    length: { maximum: 254 },
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
 # validates :password, length: { minimum: 6 }, :on => :create 
 # validates :password_confirmation, presence: true
 # validates_confirmation_of :password, :on => :create 

validates :password,
  :presence => true,
  :length => { minimum: 6},
  :confirmation => true,
  :if => lambda{ new_record? || !password.nil? }
#otherwise, same thing as below (if updated  a user, changes the remember token and ends session)

validates :first_name,
:presence => true,
:if => lambda{new_record?}

validates :last_name,
:presence => true,
:if => lambda{ new_record?}

  validates :first_name,  length: { maximum: 254 }
  validates :last_name,  length: { maximum: 254 }
  validates :password_digest,  length: { maximum: 254 }
  validates :remember_token,  length: { maximum: 254 }
  validates :recording,  length: { maximum: 254 }
  validates :phonetic,  length: { maximum: 254 }
  validates :invite_token,  length: { maximum: 254 }
  validates :password_reset_token,  length: { maximum: 254 }
  validates :company,  length: { maximum: 254 }
  validates :customer_id,  length: { maximum: 254 }


  before_save :create_remember_token,
  :if => lambda{new_record? }
# otherwise was changing the remembrer_token upon update, therby ending the session

#made this obsolete - but maybe add the loop to check for duplicated tokens in the password resets controller
  def send_password_reset
      begin
        self[:password_reset_token] = SecureRandom.urlsafe_base64
      end while User.exists?(:password_reset_token => self[:password_reset_token])
      
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
end


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

  def update_PO
    if !self.practiceobjects.nil? 
        self.practiceobjects.each do |x|
          x.update_attributes(:first_name => self.first_name, :last_name => self.last_name)
        end 
    end   
  end 

  private

    def create_remember_token
      begin
        self[:remember_token] = SecureRandom.urlsafe_base64
      end while User.exists?(:remember_token => self[:remember_token])
    end



end

# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  password_digest :string(255)
#  email           :string(255)
#  remember_token  :string(255)
#  recording       :string(255)
#  phonetic        :string(255)
#  notes           :string(255)
#  admin           :boolean
#  customer        :boolean
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

