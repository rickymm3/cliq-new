# frozen_string_literal: true

class CreateUserModerationProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :user_moderation_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :account_age_days, null: false, default: 0
      t.integer :activity_score, null: false, default: 0
      t.integer :strike_count, null: false, default: 0
      t.boolean :established, null: false, default: false
      t.datetime :snapshot_at, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end

