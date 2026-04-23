# == Schema Information
#
# Table name: lock_app_sensitive_infos
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  data_type   :string
#  data        :text
#  username    :string
#  link        :string
#  email       :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lock_app_sensitive_infos_on_user_id  (user_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LockApp::SensitiveInfo, type: :model do
  subject(:sensitive_info) do
    build(:lock_app_sensitive_info, user: user, data: 'my secret', data_type: 'Password')
  end

  let(:user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'before_save :encrypt_data' do
    it 'stores encrypted data in the database' do
      sensitive_info.save!
      raw_data = described_class.connection.execute(
        "SELECT data FROM lock_app_sensitive_infos WHERE id = #{sensitive_info.id}"
      ).first['data']
      expect(raw_data).not_to eq('my secret')
    end
  end

  describe 'after_find :decrypt_data' do
    it 'decrypts data after loading from the database' do
      sensitive_info.save!
      loaded = described_class.find(sensitive_info.id)
      expect(loaded.data).to eq('my secret')
    end
  end

  describe 'creation' do
    it 'is valid with a user and data' do
      expect(sensitive_info).to be_valid
    end

    it 'is valid without data (data is optional)' do
      empty = build(:lock_app_sensitive_info, user: user, data: nil)
      expect(empty).to be_valid
    end
  end
end
