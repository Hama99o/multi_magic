# == Schema Information
#
# Table name: bookmarks
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  bookmarkable_type :string           not null
#  bookmarkable_id   :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_bookmarks_on_bookmarkable  (bookmarkable_type,bookmarkable_id)
#  index_bookmarks_on_user_id       (user_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  subject(:bookmark) { build(:bookmark, user: user, bookmarkable: article) }

  let(:user) { create(:user) }
  let(:article) { create(:blog_app_article, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:bookmarkable) }
  end

  describe 'creation' do
    it 'is valid with a user and bookmarkable' do
      expect(bookmark).to be_valid
    end

    it 'persists to the database' do
      expect { bookmark.save }.to change(described_class, :count).by(1)
    end
  end
end
