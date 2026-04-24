# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoteApp::Note, type: :model do
  subject(:note) { build(:note, owner: owner) }

  let(:owner) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('User') }
    it { is_expected.to have_many(:shares).class_name('NoteApp::Share').dependent(:destroy) }
    it { is_expected.to have_many(:shared_with_users).through(:shares) }
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:taggings) }
    it { is_expected.to have_many(:images).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(trashed: 0, published: 1) }
  end

  describe 'creation' do
    it 'is valid with required attributes' do
      expect(note).to be_valid
    end

    it 'defaults to published status' do
      expect(note.status).to eq('published')
    end
  end

  describe '.search_notes' do
    let!(:matching_note) { create(:note, owner: owner, title: 'RSpec testing', description: 'A cool note') }
    let!(:non_matching)  { create(:note, owner: owner, title: 'Something else', description: 'Other') }

    it 'returns notes matching the query in title' do
      results = described_class.search_notes('RSpec')
      expect(results).to include(matching_note)
      expect(results).not_to include(non_matching)
    end

    it 'returns all notes when query is blank' do
      results = described_class.search_notes('')
      expect(results).to include(matching_note, non_matching)
    end
  end

  describe 'store_accessor' do
    it 'can read and write job_id via store accessor' do
      note.job_id = 'job-123'
      expect(note.job_id).to eq('job-123')
    end
  end
end
