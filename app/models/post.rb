# app/models/post.rb
class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title_truncated, use: :slugged

  belongs_to :cliq
  belongs_to :user
  has_many :replies, dependent: :destroy
  has_rich_text :content

  # 👇 Make the type explicit so enum never complains
  attribute :post_type, :integer, default: 0

  # Backed by posts.post_type (integer)
  enum post_type: { discussion: 0, article: 1, question: 2 }

  scope :ordered, -> { order(updated_at: :desc) }
  scope :articles, -> { where(post_type: :article) }  # ← convenience

  after_create :notify_followers
  after_commit :notify_followers_of_article, on: :create

  def title_truncated
    title.truncate(20, omission: '')
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  private

  def notify_followers
    return unless cliq && user_id.present?

    cliq_ids = [cliq.id]
    cliq_ids.concat(cliq.ancestors.map(&:id)) if cliq.respond_to?(:ancestors)
    cliq_ids.compact!

    subscriber_ids = Subscription.where(cliq_id: cliq_ids, enabled: true)
                                  .where.not(user_id: user_id)
                                  .distinct
                                  .pluck(:user_id)
    return if subscriber_ids.empty?

    actor_name = user.profile&.username || user.email || "Someone"
    message = "#{actor_name} posted in #{cliq.name}: #{title}"
    timestamp = Time.current

    Notification.insert_all(
      subscriber_ids.map do |recipient_id|
        {
          user_id:         recipient_id,
          actor_id:        user_id,
          notifiable_type: "Post",
          notifiable_id:   id,
          message:         message,
          created_at:      timestamp,
          updated_at:      timestamp
        }
      end
    )
  end

  def notify_followers_of_article
    return unless article? && user_id.present?

    follower_ids = FollowedUser.where(followed_id: user_id).pluck(:follower_id)
    return if follower_ids.empty?

    Notification.insert_all(
      follower_ids.map do |recipient_id|
        {
          user_id:         recipient_id,
          actor_id:        user_id,
          notifiable_type: "Post",
          notifiable_id:   id,
          message:         "New article by #{user.profile&.username || user.email || "a user"}: #{title}",
          created_at:      Time.current,
          updated_at:      Time.current
        }
      end
    )
  end
end
