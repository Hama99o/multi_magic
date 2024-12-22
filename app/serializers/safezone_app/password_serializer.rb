# == Schema Information
#
# Table name: safezone_app_passwords
#
#  id         :bigint           not null, primary key
#  owner_id   :bigint
#  status     :integer          default(0), not null
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
class SafezoneApp::PasswordSerializer < ApplicationSerializer
  identifier :id
  fields :email, :username, :link, :status, :title, :updated_at, :note, :password
  association :owner, blueprint: UserSerializer, view: :public
end
