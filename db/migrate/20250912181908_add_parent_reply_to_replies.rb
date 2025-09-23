class AddParentReplyToReplies < ActiveRecord::Migration[7.1]
  def change
    # Self-referential FK to replies
    add_reference :replies,
                  :parent_reply,
                  foreign_key: { to_table: :replies },
                  index: { unique: true }  # at most one child per parent (NULLs allowed)
  end
end
