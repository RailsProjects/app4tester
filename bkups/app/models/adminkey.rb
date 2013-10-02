class Adminkey < ActiveRecord::Base
  attr_accessible :user_id, :event_id

    belongs_to :event 
    belongs_to :user 

    validates :user_id, :uniqueness => {:scope => :event_id}
    # this is to prevent a user from having multiple admin keys for the same event - that admin_id/user_id combo can only exist once in the adminkey table

    before_create :make_user_an_admin


 private

 def make_user_an_admin
 	if !self.user.nil?
 	self.user.update_attributes(:admin => true)
    end 
 end

end
