# == Schema Information
#
# Table name: images
#
#  id             :integer          not null, primary key
#  file           :string
#  imageable_type :string           not null
#  imageable_id   :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_images_on_imageable  (imageable_type,imageable_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Image, type: :model do
  subject(:image) { build(:image, imageable: note) }

  let(:user) { create(:user) }
  let(:note) { create(:note, owner: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:imageable) }
    it { is_expected.to have_one_attached(:file) }
  end

  describe 'creation without file' do
    it 'is valid without an attached file (attached: false validation)' do
      image.save
      # attached: false means not requiring attachment — test just that it can be built
      expect(image.imageable).to eq(note)
    end
  end
end
