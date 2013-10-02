class AddPhonAndNotesToPracticeobjects < ActiveRecord::Migration
  def change
    add_column :practiceobjects, :phonetic, :string
    add_column :practiceobjects, :notes, :text
  end
end
