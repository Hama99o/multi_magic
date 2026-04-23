# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Favorite, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:favoritable) }
    it { is_expected.to belong_to(:favoritor) }
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:role)
        .with_values(viewer: 0, contributor: 1, administrator: 2, owner: 3)
    }
  end

  describe 'creation via acts_as_favoritor' do
    let(:user) { create(:user) }
    let(:note) { create(:note, owner: user) }

    it 'can be created through the favoritor interface' do
      user.favorite(note)
      expect(user.favorited?(note)).to be true
    end

    it 'can be unfavorited' do
      user.favorite(note)
      user.unfavorite(note)
      expect(user.favorited?(note)).to be false
    end
  end
end
