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

  def subscribed_to?(cliq)
    return false unless cliq
    subscribed_cliq_ids.include?(cliq.id)
  end
  
  def subscribed_cliq_ids
    @subscribed_cliq_ids ||= subscriptions.pluck(:cliq_id)
  end
end
