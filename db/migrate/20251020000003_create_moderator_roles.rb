# frozen_string_literal: true

class CreateModeratorRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :moderator_roles do |t|
      t.references :cliq, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.integer :seated_supports_count, null: false, default: 0
      t.string :status, null: false, default: "active"
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :moderator_roles, [:cliq_id, :user_id, :ended_at], name: "index_moderator_roles_on_cliq_user_ended"
    add_index :moderator_roles, :status
  end
end

