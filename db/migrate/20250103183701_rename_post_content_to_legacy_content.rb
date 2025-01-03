class RenamePostContentToLegacyContent < ActiveRecord::Migration[7.0]
  def change
    rename_column :posts, :content, :legacy_content

  end
end
