class CreateVgUserinvites < ActiveRecord::Migration
  def change
    create_table :vg_userinvites do |t|
      t.integer :voicegem_id
      t.integer :admin_id
      t.string :recipient_email
      t.datetime :sent_at
      t.string :invite_type

      t.timestamps
    end
  end
end
