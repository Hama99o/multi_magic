# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::UsersController', type: :request do
  path '/api/v1/users/connected_user' do
    rswag_prepare_connection(:user)

    get('get current user') do
      tags 'Users'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns current user') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/users/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show user') do
      tags 'Users'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns user') do
        let(:id) { user.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update user') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: { username: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'user updated') do
        let(:id) { user.id }
        let(:user_params) { { username: 'newname' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:user_params) { { username: 'newname' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
