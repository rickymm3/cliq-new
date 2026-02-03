# frozen_string_literal: true

class CreateCandidateSupports < ActiveRecord::Migration[7.1]
  def change
    create_table :candidate_supports do |t|
      t.references :user, null: false, foreign_key: true, comment: "Supporter"
      t.references :cliq, null: false, foreign_key: true
      t.references :candidate_user, null: false, foreign_key: { to_table: :users }
      t.references :post, null: false, foreign_key: true, comment: "Moderation post representing the candidacy"
      t.decimal :weight, precision: 8, scale: 2, null: false, default: 1.0

      t.timestamps
    end

    add_index :candidate_supports, [:user_id, :cliq_id, :candidate_user_id], unique: true, name: "index_candidate_supports_on_unique_supports"
    add_index :candidate_supports, [:cliq_id, :candidate_user_id]
  end
end
