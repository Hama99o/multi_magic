# == Schema Information
#
# Table name: reactions
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  type              :string
#  reactionable_type :string           not null
#  reactionable_id   :integer          not null
#  reaction_type     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_reactions_on_reactionable  (reactionable_type,reactionable_id)
#  index_reactions_on_user_id       (user_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reaction::Like, type: :model do
  let(:user) { create(:user) }
  let(:article) { create(:blog_app_article, user: user) }

  describe 'inheritance' do
    it 'inherits from Reaction' do
      expect(described_class.superclass).to eq(Reaction)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reactionable) }
  end

  describe 'creation' do
    it 'stores the correct STI type' do
      like = described_class.create!(user: user, reactionable: article)
      expect(like.type).to eq('Reaction::Like')
    end
  end
end
