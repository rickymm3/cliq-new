class CreateFollowedUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :followed_users do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followed, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :followed_users, [:follower_id, :followed_id], unique: true
  end
end
