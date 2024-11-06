# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  tokens                 :jsonb
#  firstname              :string           default(""), not null
#  lastname               :string           default(""), not null
#  birth_date             :date
#  join_date              :date
#  authentication_token   :string
#  phone_number           :string           default(""), not null
#  gender                 :string           default(""), not null
#  job_title              :string           default(""), not null
#  linkedin               :string           default(""), not null
#  access_level           :integer          default("employee"), not null
#  status                 :integer          default("active"), not null
#  timezone               :string           default("Europe/Paris")
#  lang                   :string           default("en")
#  locked_at              :datetime
#  strikes_count          :integer          default(0)
#  agreed_to_terms        :boolean
#  applications           :jsonb
#  data                   :jsonb
#  current_application    :integer          default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_code           :string
#  username               :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
class UserSerializer < ApplicationSerializer
  identifier :id

  view :private do
    include_view :online

    fields :email, :lang, :status, :birth_date, :note_index_type, :theme, :applications, :created_at, :country_code, :gender, :phone_number, :last_sign_in_at, :username

    field :access_level, if: ->(_field_name, user, options) { user.access_level == "super_admin" } do |user, options|
      user.access_level
    end

    field :fullname do |user|
      user.fullname.presence
    end

    field :firstname do |user|
      user.firstname.presence
    end

    field :lastname do |user|
      user.lastname.presence
    end

    field :cover_photo do |user|
      user.get_cover_photo_url.presence if user&.cover_photo&.attached?
    end

    field :email do |user|
      user.email.presence
    end

    field :avatar do |user|
      user.get_photo_url.presence if user&.photo&.attached?
    end

    field :following_count do |user|
      user.following.count
    end

    field :followers_count do |user|
      user.followers.count
    end

    field :is_following do |user, options|
      current_user = options[:current_user]
      next unless current_user.present?
      current_user.following?(user)
    end

    field :is_blocking do |user, options|
      current_user = options[:current_user]
      next unless current_user.present?
      current_user.blocking?(user)
    end
  end

  view :note_rights do
    include_view :online

    fields :email, :lang, :status, :birth_date, :note_index_type, :theme, :applications, :created_at, :country_code, :gender, :phone_number, :last_sign_in_at, :username

    field :access_level, if: ->(_field_name, user, options) { user.access_level == "super_admin" } do |user, options|
      user.access_level
    end

    field :fullname do |user|
      user.fullname.presence
    end

    field :firstname do |user|
      user.firstname.presence
    end

    field :lastname do |user|
      user.lastname.presence
    end

    field :cover_photo do |user|
      user.get_cover_photo_url.presence if user&.cover_photo&.attached?
    end

    field :email do |user|
      user.email.presence
    end

    field :avatar do |user|
      user.get_photo_url.presence if user&.photo&.attached?
    end

    field :note_role do |user, options|
      note = options[:note]
      note.shares.find_by(shared_with_user: user)&.role
    end
  end

  view :me do
    include_view :online

    fields :email, :lang, :status, :birth_date, :note_index_type, :theme, :applications, :created_at, :country_code, :gender, :phone_number, :last_sign_in_at, :username

    field :access_level, if: ->(_field_name, user, options) { user.access_level == "super_admin" } do |user, options|
      user.access_level
    end

    field :fullname do |user|
      user.fullname.presence
    end

    field :firstname do |user|
      user.firstname.presence
    end

    field :lastname do |user|
      user.lastname.presence
    end

    field :cover_photo do |user|
      user.get_cover_photo_url.presence if user&.cover_photo&.attached?
    end

    field :email do |user|
      user.email.presence
    end

    field :avatar do |user|
      user.get_photo_url.presence if user&.photo&.attached?
    end

    view :note_rights do
      field :note_role do |user, options|
        note = options[:note]
        note.shares.find_by(shared_with_user: user)&.role
      end
    end

    field :is_impersonating, if: ->(_field_name, object, options) { options[:true_user] && options[:true_user]['access_level'] == "super_admin" } do |user, options|
      user && options[:true_user] && user['id'] != options[:true_user]['id']
    end
  end

  view :public do
    include_view :online

    field :username do |user|
      user.username.presence
    end

    field :fullname do |user|
      user.fullname.presence
    end

    field :firstname do |user|
      user.firstname.presence
    end

    field :lastname do |user|
      user.lastname.presence
    end

    field :email do |user|
      user.email.presence
    end

    field :avatar do |user|
      user.get_photo_url.presence if user&.photo&.attached?
    end

    field :is_following do |user, options|
      current_user = options[:current_user]
      next unless current_user.present?
      current_user.following?(user)
    end
  end

  view :online do
    fields :username

    field :is_online do |user|
      next false unless user&.last_sign_in_at
      user&.last_sign_in_at > 3.minutes.ago
    end
  end
end
