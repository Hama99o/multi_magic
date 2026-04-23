# frozen_string_literal: true

# == Schema Information
#
# Table name: email_records
#
#  id              :bigint           not null, primary key
#  email           :string
#  shareable_type  :string
#  shareable_id    :bigint
#  additional_info :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_email_records_on_shareable  (shareable_type,shareable_id)
#  index_email_records_unique        (email,shareable_type,shareable_id) UNIQUE
#
require 'rails_helper'

RSpec.describe EmailRecord, type: :model do
  subject(:email_record) do
    build(:email_record, email: 'test@example.com', shareable: article)
  end

  let(:user) { create(:user) }
  let(:article) { create(:blog_app_article, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:shareable) }
  end

  describe 'store_accessor' do
    it 'can read and write role via store accessor' do
      email_record.role = 'admin'
      expect(email_record.role).to eq('admin')
    end
  end

  describe 'creation' do
    it 'is valid with an email and shareable' do
      expect(email_record).to be_valid
    end
  end
end
