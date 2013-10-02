class AddEmailAndTokenIndicesToPracticeobjects < ActiveRecord::Migration
  def change
  	add_index :practiceobjects, :email
    add_index :practiceobjects, :token
  end
end
