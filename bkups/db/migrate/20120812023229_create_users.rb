class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :password_digest
      t.string :email
      t.string :remember_token
      t.string :recording
      t.string :phonetic
      t.string :notes
      t.boolean :admin
      t.boolean :customer

      t.timestamps
    end
  end
end
