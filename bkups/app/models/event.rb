class Event < ActiveRecord::Base
  attr_accessible :access_code, :date, :event_code, :title, :purchase_type, :event_type, :master, :grad_array, :grad_date
  
  serialize :grad_array, Array
  
  has_many :customerkeys
 # has_one :customer, through: :customerkey, source: :user
  #check if this is the correct code

  has_many :adminkeys
  has_many :admins, through: :adminkeys, source: :user

  has_many :practiceobjects
  has_many :practiceusers, through: :practiceobjects, source: :user

  has_many :admininvites 

  has_many :voicegems
  has_many :vgusers, through: :voicegems, source: :user

  validates :date, :presence => true
  validates :title, :presence => true, length: { maximum: 254 }

  validates :access_code,  length: { maximum: 254 }
  validates :event_code,  length: { maximum: 254 }

  before_create :generate_access_code

  default_scope order(:date)


private 

  def generate_access_code #for admin code
      y = Digest::SHA1.hexdigest([Time.now, rand].join)[4..8].upcase 

      if Event.find_by_access_code(y)
        generate_access_code
      else
        self.access_code = y
      end 

  end




end 