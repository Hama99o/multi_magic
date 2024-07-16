# frozen_string_literal: true

# == Schema Information
#
# Table name: note_app_notes
#
#  id          :bigint           not null, primary key
#  owner_id    :bigint
#  status      :integer          default("trashed"), not null
#  data        :jsonb
#  title       :string
#  description :text
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_note_app_notes_on_owner_id  (owner_id)
#
FactoryBot.define do
  factory :note, class: 'NoteApp::Note' do
    title { Faker::Book.title }
    description { Faker::Lorem.paragraph }
    status { :published }
    owner factory: %i[user]
  end
end
