# == Schema Information
#
# Table name: follows
#
#  id          :integer          not null, primary key
#  follower_id :integer          not null
#  followed_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_follows_on_followed_id                  (followed_id)
#  index_follows_on_follower_id                  (follower_id)
#  index_follows_on_follower_id_and_followed_id  (follower_id,followed_id) UNIQUE
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Follow, type: :model do
  subject(:follow) { build(:follow, follower: create(:user), followed: create(:user)) }

  describe 'associations' do
    it { is_expected.to belong_to(:follower).class_name('User') }
    it { is_expected.to belong_to(:followed).class_name('User') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:follower_id) }
    it { is_expected.to validate_presence_of(:followed_id) }

    it 'validates uniqueness of follower_id scoped to followed_id' do
      follower = create(:user)
      followed = create(:user)
      create(:follow, follower: follower, followed: followed)
      duplicate = build(:follow, follower: follower, followed: followed)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'creation' do
    it 'is valid with a follower and followed' do
      expect(follow).to be_valid
    end
  end
end
