class AddExplanationToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :explanation, :text
  end
end
