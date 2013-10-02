class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :recipient_email
      t.string :from_email
      t.text :body
      t.datetime :sent_at
      t.string :cc_email

      t.timestamps
    end
  end
end
