# == Schema Information
#
# Table name: email_records
#
#  id              :bigint           not null, primary key
#  email           :string
#  shareable_type  :string
#  shareable_id    :bigint
#  additional_info :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_email_records_on_shareable  (shareable_type,shareable_id)
#  index_email_records_unique        (email,shareable_type,shareable_id) UNIQUE
#
require 'rails_helper'

RSpec.describe EmailRecord, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
