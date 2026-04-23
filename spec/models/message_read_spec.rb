# frozen_string_literal: true

# == Schema Information
#
# Table name: message_reads
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  message_id :integer          not null
#  read_at    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_message_reads_on_message_id  (message_id)
#  index_message_reads_on_user_id     (user_id)
#

require 'rails_helper'

RSpec.describe MessageRead, type: :model do
  subject(:message_read) do
    build(:message_read,
          user: create(:user),
          message: create(:message,
                          conversation: create(:conversation),
                          user: create(:user)))
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:message) }
  end

  describe 'creation' do
    it 'is valid with a user and message' do
      expect(message_read).to be_valid
    end

    it 'persists to the database' do
      expect { message_read.save }.to change(described_class, :count).by(1)
    end
  end
end
