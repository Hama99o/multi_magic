# == Schema Information
#
# Table name: safezone_app_passwords
#
#  id         :bigint           not null, primary key
#  owner_id   :bigint
#  status     :integer          default(0), not null
#  data       :jsonb
#  title      :string
#  email      :string
#  link       :string
#  username   :string
#  note       :jsonb
#  deleted_at :datetime
#  password   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_safezone_app_passwords_on_owner_id  (owner_id)
#
class SafezoneApp::Password < ApplicationRecord

  belongs_to :owner, class_name: "User", foreign_key: "owner_id"


  include PgSearch::Model

  pg_search_scope :search_passwords,
                  against: [:title, :data, :link, :password, :email, :username],
                  # associated_against: {
                  #   owner: %i[lastname firstname]
                  # },
                  using: {
                    tsearch: { prefix: true }
                  }
end
