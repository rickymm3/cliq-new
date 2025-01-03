class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title_truncated, use: :slugged

  belongs_to :cliq
  belongs_to :user
  has_many :replies, dependent: :destroy

  scope :ordered, -> { order(updated_at: :desc) }
  has_rich_text :content

  def title_truncated
    title.truncate(20, omission: '') # Truncate title to 20 characters without an ellipsis
  end

  # Ensure a new friendly ID is generated if the title changes
  def should_generate_new_friendly_id?
    title_changed? || super
  end
end