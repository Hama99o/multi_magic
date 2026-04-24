# == Schema Information
#
# Table name: lock_app_sensitive_infos
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  data_type   :string
#  data        :text
#  username    :string
#  link        :string
#  email       :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lock_app_sensitive_infos_on_user_id  (user_id)
#

class LockApp::SensitiveInfo < ApplicationRecord
  belongs_to :user

  # Encrypt sensitive data before saving to the database
  before_save :encrypt_data

  # Decrypt sensitive data when reading from the database
  after_find :decrypt_data

  private

  def encryption_cipher
    key = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base)
                                     .generate_key('LockApp::SensitiveInfo', 32)
    ActiveSupport::MessageEncryptor.new(key)
  end

  def encrypt_data
    self.data = encryption_cipher.encrypt_and_sign(data) if data.present?
  end

  def decrypt_data
    self.data = encryption_cipher.decrypt_and_verify(data) if data.present?
  end
end
