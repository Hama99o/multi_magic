# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::SafezoneApp::PasswordsController', type: :request do
  path '/api/v1/safezone_app/passwords' do
    rswag_prepare_connection(:user)

    get('list passwords') do
      tags 'SafezoneApp::Passwords'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns passwords') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create password') do
      tags 'SafezoneApp::Passwords'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :password_params, in: :body, schema: {
        type: :object,
        properties: {
          website: { type: :string },
          username: { type: :string },
          password: { type: :string }
        }
      }
      rswag_auth_from(:user)

      response(201, 'password created') do
        let(:password_params) { { password: { title: 'Test', link: 'https://example.com', username: 'admin', password: 'secret123' } } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:password_params) { { website: 'example.com' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/safezone_app/passwords/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show password') do
      tags 'SafezoneApp::Passwords'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns password') do
        let(:sz_password) { create(:safezone_app_passwords, owner: user) }
        let(:id) { sz_password.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update password') do
      tags 'SafezoneApp::Passwords'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :password_params, in: :body, schema: {
        type: :object,
        properties: { website: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'password updated') do
        let(:sz_password) { create(:safezone_app_passwords, owner: user) }
        let(:id) { sz_password.id }
        let(:password_params) { { password: { link: 'https://updated.com' } } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:password_params) { { password: { link: 'https://updated.com' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy password') do
      tags 'SafezoneApp::Passwords'
      produces 'application/json'
      rswag_auth_from(:user)

      response(204, 'password deleted') do
        let(:sz_password) { create(:safezone_app_passwords, owner: user) }
        let(:id) { sz_password.id }

        run_test! { expect(response).to have_http_status(:no_content) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
