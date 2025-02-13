# app/models/post.rb
class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title_truncated, use: :slugged

  belongs_to :cliq
  belongs_to :user
  has_many :replies, dependent: :destroy
  has_rich_text :content

  scope :ordered, -> { order(updated_at: :desc) }

  after_create :notify_followers  # NEW: Callback to create notifications

  def title_truncated
    title.truncate(20, omission: '')
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  private

  def notify_followers
    # Create a notification for each follower
    user.followers.find_each do |follower|
      Notification.create!(
        user: follower,
        notifiable: self,
        message: "#{user.profile.username} posted a new update"
      )
    end
  end
end
