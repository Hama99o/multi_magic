# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::SafezoneApp::IdentitiesController', type: :request do
  path '/api/v1/safezone_app/identities' do
    rswag_prepare_connection(:user)

    get('list identities') do
      tags 'SafezoneApp::Identities'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns identities') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create identity') do
      tags 'SafezoneApp::Identities'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :identity_params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          identity_number: { type: :string }
        }
      }
      rswag_auth_from(:user)

      response(201, 'identity created') do
        let(:identity_params) { { identity: { type: 'SafezoneApp::Identities::Passport', document_number: 'P123456789' } } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:identity_params) { { identity: { type: 'SafezoneApp::Identities::Passport', document_number: 'P123456789' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/safezone_app/identities/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show identity') do
      tags 'SafezoneApp::Identities'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns identity') do
        let(:identity) { create(:identity, user: user) }
        let(:id) { identity.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update identity') do
      tags 'SafezoneApp::Identities'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :identity_params, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'identity updated') do
        let(:identity) { create(:identity, user: user) }
        let(:id) { identity.id }
        let(:identity_params) { { identity: { document_number: 'P999' } } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:identity_params) { { identity: { document_number: 'P999' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy identity') do
      tags 'SafezoneApp::Identities'
      produces 'application/json'
      rswag_auth_from(:user)

      response(204, 'identity deleted') do
        let(:identity) { create(:identity, user: user) }
        let(:id) { identity.id }

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
