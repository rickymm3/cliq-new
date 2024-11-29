class Reply < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  after_create :update_post_timestamp

  validates :content, presence: true

  private

  def update_post_timestamp
    post.touch
  end
  
end
