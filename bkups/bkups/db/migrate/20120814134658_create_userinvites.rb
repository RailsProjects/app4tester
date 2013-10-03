class CreateUserinvites < ActiveRecord::Migration
  def change
    create_table :userinvites do |t|
      t.integer :practiceobject_id
      t.integer :admin_id
      t.string :recipient_email
      t.datetime :sent_at

      t.timestamps
    end
  end
end
