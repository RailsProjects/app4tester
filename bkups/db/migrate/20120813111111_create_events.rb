class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :date
      t.string :access_code
      t.string :event_code

      t.timestamps
    end
  end
end
