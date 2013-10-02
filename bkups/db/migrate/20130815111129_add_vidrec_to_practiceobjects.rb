class AddVidrecToPracticeobjects < ActiveRecord::Migration
  def change
    add_column :practiceobjects, :vidrec, :string
  end
end
