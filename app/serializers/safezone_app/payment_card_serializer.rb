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
class SafezoneApp::PaymentCardSerializer < ApplicationSerializer
  identifier :id
  fields :name, :card_type, :card_number, :expiry_date, :cvv, :status, :note, :updated_at
  association :owner, blueprint: UserSerializer, view: :public
end
