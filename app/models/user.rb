# app/models/user.rb
class User < ApplicationRecord
  # Removed FriendlyId code (no longer using user.slug)

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  has_many :posts
  has_many :replies, dependent: :destroy

  # Following associations using FollowedUser model
  has_many :active_followed_users, class_name: "FollowedUser", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_followed_users, class_name: "FollowedUser", foreign_key: "followed_id", dependent: :destroy

  has_many :followed_users, through: :active_followed_users, source: :followed
  has_many :followers, through: :passive_followed_users, source: :follower

  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_cliqs, through: :subscriptions, source: :cliq

  # ---------- Subscriptions helpers (query Subscription directly to avoid recursion) ----------

  # Returns the Subscription (if any) for the given cliq
  def subscription_for(cliq)
    return nil unless cliq
    Subscription.find_by(user_id: id, cliq_id: cliq.id)
  end

  # If this cliq is covered by an ancestor subscription, return that ancestor cliq; otherwise nil
  def subscribed_ancestor_for(cliq)
    return nil unless cliq
    subscribed_ids = Subscription.where(user_id: id).pluck(:cliq_id)
    node = cliq.parent_cliq
    while node
      return node if subscribed_ids.include?(node.id)
      node = node.parent_cliq
    end
    nil
  end

  # Collect all descendant cliq IDs under the given cliq (children, grandchildren, ...)
  def descendant_ids_for(cliq)
    return [] unless cliq
    ids = []
    stack = cliq.child_cliqs.to_a
    until stack.empty?
      c = stack.pop
      ids << c.id
      stack.concat(c.child_cliqs)
    end
    ids
  end

  # EFFECTIVE enabled subscriptions: only enabled ones, pruned so that
  # if an enabled ancestor exists, drop enabled descendants to avoid duplicates.
  def effective_enabled_subscription_ids
    subs = Subscription.where(user_id: id, enabled: true).includes(:cliq)
    return [] if subs.blank?

    sub_ids_array = subs.map(&:cliq_id)
    enabled_cliqs = subs.map(&:cliq)

    effective = enabled_cliqs.reject do |c|
      p = c.parent_cliq
      covered = false
      while p
        if sub_ids_array.include?(p.id)
          covered = true
          break
        end
        p = p.parent_cliq
      end
      covered
    end

    effective.map(&:id)
  end

  # ---------- Social helpers ----------

  # Follows another user (if not self and not already following)
  def follow(other_user)
    return if self == other_user || following?(other_user)
    active_followed_users.create!(followed: other_user)
  end

  # Unfollows a user
  def unfollow(other_user)
    relation = active_followed_users.find_by(followed: other_user)
    relation.destroy if relation
  end

  # Returns true if following the other user
  def following?(other_user)
    followed_users.exists?(other_user.id)
  end

  # ---------- Convenience checks ----------

  def subscribed_to?(cliq)
    return false unless cliq
    Subscription.exists?(user_id: id, cliq_id: cliq.id)
  end

  def subscribed_cliq_ids
    @subscribed_cliq_ids ||= Subscription.where(user_id: id).pluck(:cliq_id)
  end
end
