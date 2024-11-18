class Profile < ApplicationRecord
  belongs_to :user
  validates :username, presence: true, uniqueness: { case_sensitive: false }
end