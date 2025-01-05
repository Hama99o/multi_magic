# == Schema Information
#
# Table name: safezone_app_payment_cards
#
#  id          :bigint           not null, primary key
#  owner_id    :bigint
#  status      :integer          default("trashed"), not null
#  name        :string
#  card_type   :integer          default("credit_card"), not null
#  card_number :string
#  cvv         :string
#  expiry_date :string
#  deleted_at  :datetime
#  note        :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_safezone_app_payment_cards_on_owner_id  (owner_id)
#
class SafezoneApp::PaymentCard < ApplicationRecord
  belongs_to :owner, class_name: User.name, foreign_key: :owner_id


  before_create :set_default_value_of_data

  enum status: {
    trashed: 0,
    published: 1
  }

  enum card_type: {
    credit_card: 0,
    debit_card: 1
  }

  include PgSearch::Model
  pg_search_scope :search_cards,
                  against: [:name, :card_type, :note],
                  using: {
                    tsearch: { prefix: true }
                  }

  def set_default_value_of_data
    self.note ||= ''
  end
end
