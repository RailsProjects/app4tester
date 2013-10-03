class AddRecordingToPracticeobjects < ActiveRecord::Migration
  def change
    add_column :practiceobjects, :recording, :string
  end
end
