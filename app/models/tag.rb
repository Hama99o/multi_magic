# == Schema Information
#
# Table name: tags
#
#  id          :bigint           not null, primary key
#  name        :string
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#  parent_id   :bigint
#  position    :integer
#  description :string
#
# Indexes
#
#  index_tags_on_user_id  (user_id)
#
class Tag < ApplicationRecord
  has_many :subcategories, class_name: "Tag", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent_category, class_name: "Tag", optional: true, foreign_key: "parent_id"

  acts_as_favoritable

  acts_as_favoritor
  
  acts_as_list
  # Validation to ensure name is present
  validates :name, presence: true

  # Scope to get only parent categories (tags with no parent_id)
  scope :parent_categories, -> { where(parent_id: nil) }

  # Optional: PGSearch scope for search capability
  include PgSearch::Model
  pg_search_scope :search_tags,
                  against: [:name],
                  using: {
                    tsearch: { prefix: true }
                  }
end
