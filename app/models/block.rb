# == Schema Information
#
# Table name: blocks
#
#  id         :bigint           not null, primary key
#  blocker_id :bigint           not null
#  blocked_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_blocks_on_blocked_id                 (blocked_id)
#  index_blocks_on_blocker_id                 (blocker_id)
#  index_blocks_on_blocker_id_and_blocked_id  (blocker_id,blocked_id) UNIQUE
#
class Block < ApplicationRecord
  belongs_to :blocker, class_name: 'User'
  belongs_to :blocked, class_name: 'User'

  validates :blocker_id, presence: true
  validates :blocked_id, presence: true
  validates :blocker_id, uniqueness: { scope: :blocked_id }
end
