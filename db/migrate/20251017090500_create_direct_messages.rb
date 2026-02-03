class CreateDirectMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :direct_messages do |t|
      t.references :conversation,
                    null: false,
                    foreign_key: { to_table: :direct_message_conversations },
                    index: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :direct_messages, %i[recipient_id read_at]
  end
end
