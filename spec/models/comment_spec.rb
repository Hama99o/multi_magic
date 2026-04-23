# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text
#  user_id          :integer          not null
#  parent_id        :integer
#  commentable_type :string           not null
#  commentable_id   :integer          not null
#  data             :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_comments_on_commentable_type_and_commentable_id  (commentable_type,commentable_id)
#  index_comments_on_parent_id                            (parent_id)
#  index_comments_on_user_id                              (user_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject(:comment) do
    build(:comment, user: user, commentable: article)
  end

  let(:user) { create(:user) }
  let(:article) { create(:blog_app_article, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:commentable) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:parent).class_name('Comment').optional }
    it { is_expected.to have_many(:replies).class_name('Comment').dependent(:destroy) }
    it { is_expected.to have_many(:reactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:body) }
  end

  describe 'polymorphic commentable' do
    it 'can be associated with a BlogApp::Article' do
      comment.commentable = article
      expect(comment).to be_valid
    end
  end

  describe 'replies' do
    let!(:parent_comment) { create(:comment, user: user, commentable: article) }
    let!(:reply) { create(:comment, user: user, commentable: article, parent: parent_comment) }

    it 'associates replies to a parent comment' do
      expect(parent_comment.replies).to include(reply)
    end

    it 'sets parent on a reply' do
      expect(reply.parent).to eq(parent_comment)
    end
  end
end
