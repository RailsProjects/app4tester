class AddEventTypeToPlanseventType < ActiveRecord::Migration
  def change
  	add_column :plans, :event_type, :string
  end
end
