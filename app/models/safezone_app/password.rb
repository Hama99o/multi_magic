# == Schema Information
#
# Table name: safezone_app_passwords
#
#  id         :bigint           not null, primary key
#  owner_id   :bigint
#  status     :integer          default(0), not null
#  data       :jsonb
#  email      :string
#  link       :string
#  username   :string
#  note       :jsonb
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_safezone_app_passwords_on_owner_id  (owner_id)
#
class SafezoneApp::Password < ApplicationRecord

  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

  # Encrypt sensitive fields
  before_save :encrypt_fields

  def encrypt_fields
    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secret_key_base.byteslice(0..31))
    self.email = crypt.encrypt_and_sign(email) if email_changed?
    self.link = crypt.encrypt_and_sign(link) if link_changed?
    self.username = crypt.encrypt_and_sign(username) if username_changed?
    self.note = crypt.encrypt_and_sign(note) if note_changed?
  end

  def decrypt_fields
    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secret_key_base.byteslice(0..31))
    {
      email: crypt.decrypt_and_verify(email),
      link: crypt.decrypt_and_verify(link),
      username: crypt.decrypt_and_verify(username),
      note: crypt.decrypt_and_verify(note)
    }
  end
end
