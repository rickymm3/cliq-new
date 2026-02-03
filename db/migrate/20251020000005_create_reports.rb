# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :reportable, polymorphic: true, null: false
      t.references :cliq, null: false, foreign_key: true, comment: "Cliq where the content lived at report time"
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.string :reason, null: false
      t.text :note
      t.string :state, null: false, default: "pending"
      t.datetime :escalated_at
      t.references :escalated_to_cliq, foreign_key: { to_table: :cliqs }
      t.datetime :sla_expires_at
      t.datetime :resolved_at
      t.references :resolved_by, foreign_key: { to_table: :users }
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :reports, [:cliq_id, :state]
    add_index :reports, :sla_expires_at
  end
end

