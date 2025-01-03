class Reply < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  after_create :update_post_timestamp

  validates :content, presence: true
  has_rich_text :content 
  private

  def update_post_timestamp
    post.touch
  end
  
end
