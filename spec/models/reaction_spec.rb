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

RSpec.describe Reaction, type: :model do
  subject(:reaction) { build(:reaction, user: user, reactionable: article) }

  let(:user) { create(:user) }
  let(:article) { create(:blog_app_article, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reactionable) }
  end

  describe 'creation' do
    it 'is valid with a user and reactionable' do
      expect(reaction).to be_valid
    end

    it 'persists to the database' do
      expect { reaction.save }.to change(described_class, :count).by(1)
    end
  end
end
