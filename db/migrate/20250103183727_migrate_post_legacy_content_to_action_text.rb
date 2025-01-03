class MigratePostLegacyContentToActionText < ActiveRecord::Migration[7.0]
  def up
    Post.find_each do |post|
      next if post.legacy_content.blank?

      # We call #update_column or #update! on :content,
      # which now references the ActionText association.
      # That triggers creation of a rich_text record under the hood.
      post.update!(content: post.legacy_content)
    end
  end
  def down
    # Optionally, if you want to revert:
    Post.find_each do |post|
      # Move content back to legacy_content 
      # (assuming #content is stored as HTML in Action Text)
      if post.content.body.present?
        post.update_column(:legacy_content, post.content.to_s)
      end
    end
  end
end
