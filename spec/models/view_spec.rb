# == Schema Information
#
# Table name: views
#
#  id            :integer          not null, primary key
#  viewable_type :string           not null
#  viewable_id   :integer          not null
#  user_id       :integer
#  ip_address    :string
#  user_agent    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_views_on_user_id                (user_id)
#  index_views_on_viewable               (viewable_type,viewable_id)
#  index_views_on_viewable_and_ip_agent  (viewable_type,viewable_id,ip_address,user_agent) UNIQUE
#  index_views_on_viewable_and_user      (viewable_type,viewable_id,user_id) UNIQUE
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe View, type: :model do
  subject(:view_record) { build(:view, user: user, viewable: article) }

  let(:user) { create(:user) }
  let(:article) { create(:blog_app_article, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:viewable) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'creation' do
    it 'is valid with a user and viewable' do
      expect(view_record).to be_valid
    end

    it 'can be created without a user (guest view)' do
      guest_view = build(:view, user: nil, viewable: article, ip_address: '1.2.3.4')
      expect(guest_view).to be_valid
    end
  end
end
