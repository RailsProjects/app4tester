class CreateVoicegems < ActiveRecord::Migration
  def change
    create_table :voicegems do |t|
      t.integer :user_id
      t.integer :event_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.text :admin_notes
      t.integer :vg_userinvite_id
      t.integer :admin_id
      t.string :token
      t.string :recording
      t.string :request
      t.text :notes
      t.boolean :hidden
      t.integer :length

      t.timestamps
    end
  end
end
