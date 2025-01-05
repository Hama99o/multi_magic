# == Schema Information
#
# Table name: safezone_app_identities
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  type            :string           not null
#  document_number :string           not null
#  issued_at       :date
#  expires_at      :date
#  image           :string
#  data            :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_safezone_app_identities_on_user_id  (user_id)
#
class SafezoneApp::Identity < ApplicationRecord
  belongs_to :user

  validates :type, presence: true
  validates :document_number, presence: true

  before_create :set_default_value_of_data

  store_accessor :data,
                :note

  include PgSearch::Model
  pg_search_scope :search_identities,
                  against: [:type, :document_number, :data],
                  using: {
                    tsearch: { prefix: true }
                  }

  def set_default_value_of_data
    self.note ||= ''
  end
end
