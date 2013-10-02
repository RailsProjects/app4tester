class CreatePracticeobjects < ActiveRecord::Migration
  def change
    create_table :practiceobjects do |t|
      t.integer :user_id
      t.integer :event_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :admin_notes
      t.integer :userinvite_id
      t.integer :admin_id
      t.string :token

      t.timestamps
    end
  end
end
