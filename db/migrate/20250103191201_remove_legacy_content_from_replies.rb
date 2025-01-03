class RemoveLegacyContentFromReplies < ActiveRecord::Migration[7.0]
  def change
    remove_column :replies, :legacy_content, :text
  end
end
