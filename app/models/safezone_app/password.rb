# frozen_string_literal: true

# == Schema Information
#
# Table name: safezone_app_passwords
#
#  id         :bigint           not null, primary key
#  owner_id   :bigint
#  status     :integer          default("trashed"), not null
#  data       :jsonb
#  title      :string
#  email      :string
#  link       :string
#  username   :string
#  note       :jsonb
#  deleted_at :datetime
#  password   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_safezone_app_passwords_on_owner_id  (owner_id)
#
module SafezoneApp
  class Password < ApplicationRecord
    belongs_to :owner, class_name: 'User'

    enum :status, {
      trashed: 0,
      published: 1
    }

    include PgSearch::Model

    pg_search_scope :search_passwords,
                    against: %i[title data link password email username],
                    # associated_against: {
                    #   owner: %i[lastname firstname]
                    # },
                    using: {
                      tsearch: { prefix: true }
                    }
  end
end
