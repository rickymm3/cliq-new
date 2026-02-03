# frozen_string_literal: true

class CreateModerationDelegations < ActiveRecord::Migration[7.1]
  def change
    create_table :moderation_delegations do |t|
      t.references :delegator, null: false, foreign_key: { to_table: :users }
      t.references :delegatee, null: false, foreign_key: { to_table: :users }
      t.references :cliq, null: false, foreign_key: true
      t.datetime :granted_at, null: false
      t.datetime :revoked_at
      t.boolean :active, null: false, default: true
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :moderation_delegations, [:delegator_id, :cliq_id], unique: true, name: "index_mod_delegations_on_delegator_cliq"
    add_index :moderation_delegations, [:delegatee_id, :cliq_id], name: "index_mod_delegations_on_delegatee_cliq"
  end
end

