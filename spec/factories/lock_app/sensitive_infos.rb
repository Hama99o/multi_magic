# frozen_string_literal: true

# == Schema Information
#
# Table name: lock_app_sensitive_infos
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           not null
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
FactoryBot.define do
  factory :lock_app_sensitive_info, class: 'LockApp::SensitiveInfo' do
  end
end
