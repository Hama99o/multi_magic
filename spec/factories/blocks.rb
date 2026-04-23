# == Schema Information
#
# Table name: blocks
#
#  id         :integer          not null, primary key
#  blocker_id :integer          not null
#  blocked_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_blocks_on_blocked_id                 (blocked_id)
#  index_blocks_on_blocker_id                 (blocker_id)
#  index_blocks_on_blocker_id_and_blocked_id  (blocker_id,blocked_id) UNIQUE
#

# frozen_string_literal: true

FactoryBot.define do
  factory :block do
    association :blocker, factory: :user
    association :blocked, factory: :user
  end
end
