class AddCodeIndicesToEvents < ActiveRecord::Migration
  def change
  	add_index :events, :access_code
    add_index :events, :event_code
  end
end
