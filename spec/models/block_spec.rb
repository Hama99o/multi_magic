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

require 'rails_helper'

RSpec.describe Block, type: :model do
  subject(:block_record) { build(:block, blocker: create(:user), blocked: create(:user)) }

  describe 'associations' do
    it { is_expected.to belong_to(:blocker).class_name('User') }
    it { is_expected.to belong_to(:blocked).class_name('User') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:blocker_id) }
    it { is_expected.to validate_presence_of(:blocked_id) }

    it 'validates uniqueness of blocker_id scoped to blocked_id' do
      blocker = create(:user)
      blocked = create(:user)
      create(:block, blocker: blocker, blocked: blocked)
      duplicate = build(:block, blocker: blocker, blocked: blocked)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'creation' do
    it 'is valid with a blocker and blocked user' do
      expect(block_record).to be_valid
    end
  end
end
