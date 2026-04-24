# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  name        :string
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#  parent_id   :integer
#  position    :integer
#  description :string
#
# Indexes
#
#  index_tags_on_user_id  (user_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoteApp::Tag, type: :model do
  subject(:tag) { build(:note_tag, user: user, position: 1) }

  let(:user) { create(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:position) }

    it 'validates uniqueness of name scoped to user_id (case insensitive)' do
      create(:note_tag, name: 'Work', user: user, position: 1)
      duplicate = build(:note_tag, name: 'work', user: user, position: 2)
      expect(duplicate).not_to be_valid
    end

    it 'allows same name for different users' do
      other_user = create(:user)
      create(:note_tag, name: 'Work', user: user, position: 1)
      other_tag = build(:note_tag, name: 'Work', user: other_user, position: 1)
      expect(other_tag).to be_valid
    end
  end

  describe 'scopes' do
    it 'is ordered by position by default' do
      t3 = create(:note_tag, user: user, position: 3)
      t1 = create(:note_tag, user: user, position: 1)
      t2 = create(:note_tag, user: user, position: 2)
      expect(described_class.all.to_a).to eq([t1, t2, t3])
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
  end
end
