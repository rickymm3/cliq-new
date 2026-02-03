# frozen_string_literal: true

class CreateModerationActions < ActiveRecord::Migration[7.1]
  def change
    create_table :moderation_actions do |t|
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.references :cliq, null: false, foreign_key: true
      t.string :action_type, null: false
      t.references :subject, polymorphic: true, null: false
      t.references :report, foreign_key: true
      t.text :notes
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :moderation_actions, :action_type
  end
end
