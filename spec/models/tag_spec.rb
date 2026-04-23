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

RSpec.describe Tag, type: :model do
  subject(:tag) { build(:tag, name: 'Work') }

  describe 'associations' do
    it { is_expected.to have_many(:subcategories).class_name('Tag').dependent(:destroy) }
    it { is_expected.to belong_to(:parent_category).class_name('Tag').optional }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'scopes' do
    let!(:parent_tag) { create(:tag, name: 'Parent', parent_id: nil) }
    let!(:child_tag)  { create(:tag, name: 'Child') }

    before { child_tag.update!(parent_id: parent_tag.id) }

    it '.parent_categories returns only root tags' do
      expect(described_class.parent_categories).to include(parent_tag)
      expect(described_class.parent_categories).not_to include(child_tag)
    end
  end

  describe 'subcategories' do
    it 'can have subcategories' do
      parent = create(:tag, name: 'Parent')
      child  = create(:tag, name: 'Child', parent_id: parent.id)
      expect(parent.subcategories).to include(child)
    end
  end
end
