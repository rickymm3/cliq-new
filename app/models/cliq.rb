class Cliq < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  validates :name, presence: true, uniqueness: { scope: :parent_cliq_id, message: "must be unique under the same parent" }

  has_many :posts
  belongs_to :parent_cliq, class_name: 'Cliq', foreign_key: 'parent_cliq_id', optional: true
  has_many :child_cliqs, class_name: 'Cliq', foreign_key: :parent_cliq_id

  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  alias_attribute :parent, :parent_cliq
  accepts_nested_attributes_for :posts


  def slug_candidates
    [
      [:parent_cliq_id, :name]
    ]
  end

  scope :ordered, -> { order(id: :desc) }
  scope :root, -> { where(parent_cliq_id: nil) }
  scope :main_categories, -> { where.not(parent_cliq_id: nil).where('parent_cliq_id IS NOT NULL') }

  # -------- Hierarchy helpers --------

  # IDs of all descendants (children, grandchildren, ...)
  def descendant_ids
    ids = []
    stack = child_cliqs.to_a
    until stack.empty?
      c = stack.pop
      ids << c.id
      stack.concat(c.child_cliqs)
    end
    ids
  end

  # Self + all descendants
  def self_and_descendant_ids
    [id] + descendant_ids
  end

  def self.search(query)
    where("name ILIKE ?", "%#{query}%") # Use ILIKE for case-insensitive matching
  end

  def should_generate_new_friendly_id?
    name_changed? || parent_cliq_id_changed?
  end

  def ancestors
    nodes = []
    current = self
    while current.parent_cliq
      current = current.parent_cliq
      break if current.name == "Cliq" # stop at umbrella/root
      nodes << current
    end
    nodes.reverse
  end

  # subscriptions
  def root_or_self
    ancestors.any? ? ancestors.first : self
  end
end
