class AddEventIdToAdminkeys < ActiveRecord::Migration
  def change
    add_column :adminkeys, :event_id, :integer
  end
end
