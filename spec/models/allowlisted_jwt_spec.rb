# == Schema Information
#
# Table name: allowlisted_jwts
#
#  id         :integer          not null, primary key
#  jti        :string           not null
#  aud        :string
#  exp        :datetime         not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_allowlisted_jwts_on_jti      (jti) UNIQUE
#  index_allowlisted_jwts_on_user_id  (user_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllowlistedJwt, type: :model do
  subject(:allowlisted_jwt) { build(:allowlisted_jwt, user: user) }

  let(:user) { create(:user) }

  describe 'creation' do
    it 'is valid with required fields' do
      expect(allowlisted_jwt).to be_valid
    end

    it 'persists to the database' do
      expect { allowlisted_jwt.save }.to change(described_class, :count).by(1)
    end

    it 'stores jti and exp' do
      allowlisted_jwt.save!
      expect(allowlisted_jwt.jti).to be_present
      expect(allowlisted_jwt.exp).to be_present
    end
  end
end
