class AddHeatDecayFieldsToPosts < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:posts, :heat_score)
      add_column :posts, :heat_score, :float, null: false, default: 0.0
    end

    unless column_exists?(:posts, :hot_until)
      add_column :posts, :hot_until, :datetime
    end

    unless column_exists?(:posts, :heat_score_updated_at)
      add_column :posts, :heat_score_updated_at, :datetime
    end

    add_index :posts, :hot_until unless index_exists?(:posts, :hot_until)
    add_index :posts, :heat_score unless index_exists?(:posts, :heat_score)
  end
end
