class AddEnabledToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :enabled, :boolean, default: true, null: false
  end
end
