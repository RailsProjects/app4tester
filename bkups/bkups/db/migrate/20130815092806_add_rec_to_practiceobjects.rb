class AddRecToPracticeobjects < ActiveRecord::Migration
   def self.up
    add_attachment :practiceobjects, :rec
  end

  def self.down
    remove_attachment :practiceobjects, :rec
  end
end
