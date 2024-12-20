# == Schema Information
#
# Table name: safezone_app_password_managers
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
#  index_safezone_app_password_managers_on_owner_id  (owner_id)
#
FactoryBot.define do
  factory :safezone_app_password_manager, class: 'SafezoneApp::PasswordManager' do
    
  end
end
