class AddPostTypeToPosts < ActiveRecord::Migration[7.1]
  def up
    add_column :posts, :post_type, :integer, null: false, default: 0
    add_index  :posts, :post_type
  end

  def down
    remove_index  :posts, :post_type
    remove_column :posts, :post_type
  end
end
