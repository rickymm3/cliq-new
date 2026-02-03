class AddHeatTrackingToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :heat_score, :float, null: false, default: 0.0
    add_column :posts, :hot_until, :datetime
  end
end
