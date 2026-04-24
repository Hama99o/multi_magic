# frozen_string_literal: true

module RswagHelper
  def rswag_prepare_connection(user_sym = :user, **user_attrs)
    let(user_sym) { create(:user, **user_attrs) }
    parameter name: :Authorization, in: :header, type: :string,
              description: 'Bearer JWT token (e.g. Bearer eyJ...)'
  end

  def rswag_auth_from(user_sym = :user)
    let(:Authorization) do
      u = send(user_sym)
      post '/users/login', params: { user: { email: u.email, password: u.password } }
      response.headers['Authorization']
    end
  end
end

RSpec.configure do |config|
  config.extend RswagHelper, type: :request
end
