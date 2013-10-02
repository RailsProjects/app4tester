class CreateAdminkeys < ActiveRecord::Migration
  def change
    create_table :adminkeys do |t|
      t.integer :user_id
      t.integer :admin_id

      t.timestamps
    end
  end
end
