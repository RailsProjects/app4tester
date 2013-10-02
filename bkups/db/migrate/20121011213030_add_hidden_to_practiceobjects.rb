class AddHiddenToPracticeobjects < ActiveRecord::Migration
  def change
    add_column :practiceobjects, :hidden, :boolean
  end
end
