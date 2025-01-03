class RenameReplyContentToLegacyContent < ActiveRecord::Migration[7.0]
  def change
    rename_column :replies, :content, :legacy_content

  end
end
