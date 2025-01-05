# == Schema Information
#
# Table name: note_app_notes
#
#  id          :bigint           not null, primary key
#  owner_id    :bigint
#  status      :integer          default("trashed"), not null
#  data        :jsonb
#  title       :string
#  description :text
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_note_app_notes_on_owner_id  (owner_id)
#
class NoteApp::Note < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :shares, class_name: 'NoteApp::Share', dependent: :destroy
  has_many :shared_with_users, through: :shares
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :tagging
  has_many :images, as: :imageable, dependent: :destroy

  acts_as_favoritable
  acts_as_favoritor

  enum status: {
    trashed: 0,
    published: 1
  }

  store_accessor :data,
                 :job_id,
                 :repeat_frequency,
                 :launch_time,
                 :launch_date

  def self.search_notes(query)
    return all if query.blank?

    where(
      "title ILIKE :query OR description ILIKE :query OR data::text ILIKE :query",
      query: "%#{query}%"
    )
  end
end

