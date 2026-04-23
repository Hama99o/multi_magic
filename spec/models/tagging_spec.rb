# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  tag_id        :integer          not null
#  taggable_type :string           not null
#  taggable_id   :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_taggings_on_tag_id                                    (tag_id)
#  index_taggings_on_tag_id_and_taggable_id_and_taggable_type  (tag_id,taggable_id,taggable_type) UNIQUE
#  index_taggings_on_taggable                                  (taggable_type,taggable_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tagging, type: :model do
  subject(:tagging) { build(:tagging, tag: tag, taggable: article) }

  let(:user) { create(:user) }
  let(:tag) { create(:tag) }
  let(:article) { create(:blog_app_article, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:tag) }
    it { is_expected.to belong_to(:taggable) }
  end

  describe 'creation' do
    it 'is valid with a tag and taggable' do
      expect(tagging).to be_valid
    end

    it 'persists to the database' do
      expect { tagging.save }.to change(described_class, :count).by(1)
    end
  end
end
