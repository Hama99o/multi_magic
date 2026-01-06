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
class User < ApplicationRecord
  has_many :shares, class_name: 'NoteApp::Share', foreign_key: 'shared_with_user_id', dependent: :destroy
  has_many :shared_notes, through: :shares, source: :note, class_name: 'NoteApp::Note', foreign_key: 'note_id'

  include Devise::JWT::RevocationStrategies::Allowlist
  include Rails.application.routes.url_helpers

  acts_as_favoritor
  has_many :notes, class_name: "NoteApp::Note", foreign_key: :owner_id, dependent: :nullify
  has_many :expenses, class_name: "MyFinanceApp::Expense", foreign_key: :user_id, dependent: :nullify
  has_many :loans, class_name: "MyFinanceApp::Loan", foreign_key: :user_id, dependent: :nullify
  has_many :contacts, class_name: "ContactApp::Contact", foreign_key: :user_id, dependent: :nullify
  has_many :articles, class_name: "BlogApp::Article", foreign_key: :user_id, dependent: :nullify
  has_many :safezone_app_passwords, class_name: "SafezoneApp::Password", foreign_key: :owner_id, dependent: :nullify
  has_many :safezone_app_payment_cards, class_name: SafezoneApp::PaymentCard.name, foreign_key: :owner_id
  has_many :safezone_app_identities, class_name: SafezoneApp::Identity.name, foreign_key: :user_id

  # TodoApp associations
  has_many :todo_groups, class_name: "TodoApp::TodoGroup", foreign_key: :user_id, dependent: :destroy
  has_many :todos, class_name: "TodoApp::Todo", foreign_key: :user_id, dependent: :destroy

  # Associations for Conversations
  has_many :conversation_members, dependent: :destroy
  has_many :conversations, through: :conversation_members
  has_many :message_reads, dependent: :destroy
  has_many :messages, dependent: :destroy

  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :views, dependent: :destroy

  # Follow Associations
  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  has_many :passive_follows, class_name: "Follow", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  # Block Associations
  has_many :active_blocks, class_name: "Block", foreign_key: "blocker_id", dependent: :destroy
  has_many :blocked_users, through: :active_blocks, source: :blocked

  has_many :passive_blocks, class_name: "Block", foreign_key: "blocked_id", dependent: :destroy
  has_many :blockers, through: :passive_blocks, source: :blocker

  has_many :tags, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include PgSearch::Model

  pg_search_scope :search_users,
                  against: [:firstname, :lastname, :email],
                  using: {
                    tsearch: { prefix: true }
                  }

  # Possible values for the note_index_type attribute:
  # - "table": Display notes in a table format
  # - "card_grid": Display notes in a grid of cards
  # - "card_list": Display notes in a list of cards
  store_accessor :data,
                 :note_index_type,
                 :about,
                 :theme ## dark or light or other

  validates :email, presence: true
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9]+\z/, message: "only allows letters and numbers" }

  before_create :set_default_value_of_data
  before_validation :generate_unique_username, on: :create

  has_one_attached :photo
  has_one_attached :cover_photo

  enum access_level: {
    employee: 0,
    admin: 1,
    super_admin: 2
  }

  enum status: {
    inactive: 0,
    active: 1
  }

  def set_default_value_of_data
    self.note_index_type ||= :card_list
    self.theme ||= :dark
  end

  def fullname
    "#{firstname&.titleize} #{lastname&.upcase}"
  end

  def all_notes
    NoteApp::Note.where(
      id: shared_notes.ids + notes.ids
    )
  end

  def admin_or_above?
    %i[admin super_admin].include? access_level.to_sym
  end

  def get_photo_url
    url_for(photo).presence
  end

  def get_cover_photo_url
    url_for(cover_photo).presence
  end

  def get_photo_urls
    if photo.representable?
      {
        "30" => Rails.application.routes.url_helpers.rails_blob_url(photo.variant(resize: "30")),
        "50" => Rails.application.routes.url_helpers.rails_blob_url(photo.variant(resize: "50")),
        "70" => Rails.application.routes.url_helpers.rails_blob_url(photo.variant(resize: "70")),
        "100" => Rails.application.routes.url_helpers.rails_blob_url(photo.variant(resize: "100")),
        "150" => Rails.application.routes.url_helpers.rails_blob_url(photo.variant(resize: "150"))
      }
    end
  end

  def get_cover_photo_urls
    if cover_photo.representable?
      {
        "30" => Rails.application.routes.url_helpers.rails_blob_url(cover_photo.variant(resize: "30")),
        "50" => Rails.application.routes.url_helpers.rails_blob_url(cover_photo.variant(resize: "50")),
        "70" => Rails.application.routes.url_helpers.rails_blob_url(cover_photo.variant(resize: "70")),
        "100" => Rails.application.routes.url_helpers.rails_blob_url(cover_photo.variant(resize: "100")),
        "150" => Rails.application.routes.url_helpers.rails_blob_url(cover_photo.variant(resize: "150"))
      }
    end
  end

  def reset_password!
    tokens.shift until tokens.empty? if tokens.present?
    send(:set_reset_password_token)

    UserMailer.reset_password(self).deliver_later
  end

  # Follow a user
  def follow(user)
    following << user unless self == user || blocking?(user)
  end

  # Unfollow a user
  def unfollow(user)
    following.delete(user)
  end

  # Check if following a user
  def following?(user)
    following.include?(user)
  end

  # Block a user
  def block(user)
    unfollow(user) # Unfollow if following
    blocked_users << user unless self == user
  end

  # Unblock a user
  def unblock(user)
    blocked_users.delete(user)
  end

  # Check if blocking a user
  def blocking?(user)
    blocked_users.include?(user)
  end

  # Method to update sign_in_count and last_sign_in_at
  def update_sign_in_tracking!
    self.last_sign_in_at = current_sign_in_at || Time.current
    self.current_sign_in_at = Time.current
    self.sign_in_count = (sign_in_count || 0) + 1
    save(validate: false)
  end

  def generate_unique_username
    base_username = "#{firstname}#{lastname}".gsub(/[^a-zA-Z0-9]/, '').downcase
    username_candidate = base_username
    counter = 1

    while User.exists?(username: username_candidate)
      username_candidate = "#{base_username}#{counter}"
      counter += 1
    end

    self.username ||= username_candidate
  end

  def new_user_stuff!
    send_welcome_mail
    share_notes_with_new_user!
  end

  def send_welcome_mail
    UserMailer.welcome_email(self).deliver_later
  end

  def share_notes_with_new_user!
    email_records = EmailRecord.where(email:)

    email_records.each do |email_record|
      role = email_record.additional_info['role'] || 'viewer'
      note = email_record.shareable

      if email_record.shareable_type ==  "NoteApp::Note"
        NoteApp::Share.create(shared_with_user: resource, note:, role:)
        email_record.destroy
      end
    end
  end
end
