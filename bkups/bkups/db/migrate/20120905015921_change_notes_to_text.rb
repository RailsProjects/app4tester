class ChangeNotesToText < ActiveRecord::Migration
  def change
  	change_column :practiceobjects, :admin_notes, :text
  	change_column :users, :notes, :text
  end

end
