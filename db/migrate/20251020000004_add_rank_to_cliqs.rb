# frozen_string_literal: true

class AddRankToCliqs < ActiveRecord::Migration[7.1]
  def change
    add_column :cliqs, :rank, :integer, null: false, default: 0, comment: "Enum: 0=unranked,1=bronze,2=silver,3=gold"
    add_column :cliqs, :ranked_at, :datetime
    add_column :cliqs, :rank_metadata, :jsonb, null: false, default: {}

    add_index :cliqs, :rank
    add_index :cliqs, :ranked_at
  end
end

