# frozen_string_literal: true

class AddModerationFieldsToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :visibility, :integer, null: false, default: 0, comment: "Enum tracked in Post.visibility enum"
    add_column :posts, :moderation_tagged_at, :datetime
    add_column :posts, :moderation_supports_count, :integer, null: false, default: 0
    add_index :posts, :visibility
    add_index :posts, :moderation_tagged_at
    add_index :posts, :moderation_supports_count
  end
end
