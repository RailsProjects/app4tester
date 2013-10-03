class AddNamesandemailToAdmininvite < ActiveRecord::Migration
  def change
    add_column :admininvites, :first_name, :string
    add_column :admininvites, :last_name, :string
    add_column :admininvites, :recipient_email, :string
  end
end
