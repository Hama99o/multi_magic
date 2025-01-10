# == Schema Information
#
# Table name: safezone_app_cards
#
#  id             :bigint           not null, primary key
#  owner_id       :bigint
#  status         :integer          default(0), not null
#  name           :string
#  card_type      :integer          default(0), not null
#  account_number :string
#  expiry_date    :string
#  deleted_at     :datetime
#  note           :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_safezone_app_cards_on_owner_id  (owner_id)
#
class SafezoneApp::Card < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

  include PgSearch::Model

  pg_search_scope :search_cards,
                  against: [:name, :card_type, :identifier],
                  using: {
                    tsearch: { prefix: true }
                  }
end
