# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  name        :string
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#  parent_id   :integer
#  position    :integer
#  description :string
#
# Indexes
#
#  index_tags_on_user_id  (user_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyFinanceApp::Tag, type: :model do
  subject(:tag) { build(:my_finance_app_tag, user: user) }

  let(:user) { create(:user) }

  describe 'inheritance' do
    it 'inherits from Tag' do
      expect(described_class.superclass).to eq(Tag)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:expenses).class_name('MyFinanceApp::Expense').dependent(:destroy) }
    it { is_expected.to have_many(:loans).class_name('MyFinanceApp::Loan').dependent(:nullify) }
  end

  describe 'creation' do
    it 'is valid with a name' do
      expect(tag).to be_valid
    end
  end
end
