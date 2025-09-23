class RemoveUniqueIndexFromRepliesParentReplyId < ActiveRecord::Migration[7.1]
  def change
    remove_index :replies, column: :parent_reply_id, if_exists: true
    add_index    :replies, :parent_reply_id, if_not_exists: true
  end
end
