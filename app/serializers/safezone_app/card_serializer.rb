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
class SafezoneApp::CardSerializer < ApplicationSerializer
  identifier :id
  fields :name, :card_type, :expiry_date, :status, :note, :updated_at
  association :owner, blueprint: UserSerializer, view: :public
end
