# == Schema Information
#
# Table name: safezone_app_identities
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  type            :string           not null
#  document_number :string           not null
#  issued_at       :date
#  expires_at      :date
#  image           :string
#  data            :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_safezone_app_identities_on_user_id  (user_id)
#
class SafezoneApp::Identities::Passport < SafezoneApp::Identity
end
