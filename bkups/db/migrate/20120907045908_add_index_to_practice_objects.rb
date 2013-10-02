class AddIndexToPracticeObjects < ActiveRecord::Migration
  def change
  	add_index :practiceobjects, :user_id
    add_index :practiceobjects, :event_id
  	add_index :practiceobjects, [:user_id, :event_id], unique: true
  end
end
