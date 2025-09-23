class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :cliq, null: false, foreign_key: true

      t.timestamps
    end

    add_index :subscriptions, [:user_id, :cliq_id], unique: true
  end
end
