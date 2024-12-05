class Cliq < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  validates :name, presence: true, uniqueness: { scope: :parent_cliq_id, message: "must be unique under the same parent" }
  has_many :posts
  belongs_to :parent_cliq, class_name: 'Cliq', foreign_key: 'parent_cliq_id', optional: true
  has_many :child_cliqs, class_name: 'Cliq', foreign_key: :parent_cliq_id
  alias_attribute :parent, :parent_cliq
  def slug_candidates
    [
      [:parent_cliq_id, :name]
    ]
  end
  scope :ordered, -> { order(id: :desc) }
  scope :root, -> { where(parent_cliq_id: nil) }
  scope :main_categories, -> { where.not(parent_cliq_id: nil).where('parent_cliq_id IS NOT NULL') }
  
  def self_and_descendant_ids
    @ids = [self.id] + self.child_cliqs.flat_map(&:self_and_descendant_ids)
  end

  def self.search(query)
    where("name ILIKE ?", "%#{query}%") # Use ILIKE for case-insensitive matching
  end
  
  def should_generate_new_friendly_id?
    name_changed? || parent_cliq_id_changed?
  end

end
