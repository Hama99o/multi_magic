# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogApp::Article, type: :model do
  subject(:article) { build(:blog_app_article, user: user) }

  let(:user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
    it { is_expected.to have_many(:reactions).dependent(:destroy) }
    it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
    it { is_expected.to have_many(:views).dependent(:destroy) }
    it { is_expected.to have_one_attached(:cover_photo) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(trashed: 0, draft: 1, published: 2) }
  end

  describe 'scopes' do
    let!(:published_article) { create(:blog_app_article, user: user, status: :published) }
    let!(:draft_article)     { create(:blog_app_article, user: user, status: :draft) }
    let!(:trashed_article)   { create(:blog_app_article, user: user, status: :trashed) }

    it 'returns published articles with .published scope' do
      expect(described_class.published).to include(published_article)
      expect(described_class.published).not_to include(draft_article, trashed_article)
    end

    it 'returns drafts with .drafts scope' do
      expect(described_class.drafts).to include(draft_article)
      expect(described_class.drafts).not_to include(published_article)
    end
  end

  describe 'before_create :set_default_value' do
    it 'sets description to a space when not provided' do
      new_article = create(:blog_app_article, user: user, description: nil)
      expect(new_article.description).to eq(' ')
    end

    it 'sets duration to "5" when not provided' do
      new_article = create(:blog_app_article, user: user, duration: nil)
      expect(new_article.duration).to eq('5')
    end

    it 'does not override description if already set' do
      new_article = create(:blog_app_article, user: user, description: 'custom')
      expect(new_article.description).to eq('custom')
    end
  end

  describe '#unique_view_count' do
    it 'returns the number of views' do
      article.save!
      create(:view, viewable: article, user: user)
      create(:view, viewable: article, user: create(:user))
      expect(article.unique_view_count).to eq(2)
    end
  end

  describe '#published?' do
    it 'returns true when status is published' do
      article.status = :published
      expect(article.published?).to be true
    end

    it 'returns false when status is not published' do
      article.status = :draft
      expect(article.published?).to be false
    end
  end
end
