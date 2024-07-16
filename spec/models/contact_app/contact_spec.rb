# == Schema Information
#
# Table name: contact_app_contacts
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  firstname  :string
#  lastname   :string
#  email      :string
#  phone      :string
#  address    :string
#  birth_date :date
#  status     :integer          default("trashed"), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe ContactApp::Contact, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
