# == Schema Information
#
# Table name: blog_app_articles
#
#  id           :bigint           not null, primary key
#  title        :string
#  subtitle     :text
#  published_at :datetime
#  user_id      :bigint           not null
#  deleted_at   :datetime
#  status       :integer          default("trashed"), not null
#  description  :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  duration     :string
#
# Indexes
#
#  index_blog_app_articles_on_user_id  (user_id)
#
class BlogApp::Article < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :reactions, as: :reactionable, dependent: :destroy
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy
  has_many :views, as: :viewable, dependent: :destroy

  # validates :title, :description, presence: true
  # Scopes for filtering published and draft posts
  has_one_attached :cover_photo
  scope :published, -> { where(status: :published) }
  before_create :set_default_value
  scope :drafts, -> { where(status: :draft) }

  def get_cover_photo_url
    url_for(cover_photo).presence
  end

  include PgSearch::Model
  pg_search_scope :search_articles,
                against: [:title, :description],
                associated_against: {
                  user: %i[lastname firstname]
                },
                using: {
                  tsearch: { prefix: true }
                }
  enum status: {
    trashed: 0,
    draft: 1,
    published: 2
  }

  # Optional: a helper method to count unique views
  def unique_view_count
    views.count
  end

  # Method to check if post is published
  def published?
    status == 'published'
  end

  def set_default_value
    self.description ||= ' '
    self.duration ||= '5'
  end
end
