class CreateAdmininvites < ActiveRecord::Migration
  def change
    create_table :admininvites do |t|
      t.integer :event_id
      t.string :token

      t.timestamps
    end
  end
end
