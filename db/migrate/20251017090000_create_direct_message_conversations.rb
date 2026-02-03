class CreateDirectMessageConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :direct_message_conversations do |t|
      t.references :user_a, null: false, foreign_key: { to_table: :users }
      t.references :user_b, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :direct_message_conversations,
              %i[user_a_id user_b_id],
              unique: true,
              name: "index_direct_message_conversations_on_participants"
  end
end
