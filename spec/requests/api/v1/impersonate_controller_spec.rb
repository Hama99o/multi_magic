# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::ImpersonateController', type: :request do
  path '/api/v1/impersonate/is_impersonating' do
    get('check if impersonating') do
      tags 'Impersonate'
      produces 'application/json'
      rswag_prepare_connection(:user)
      rswag_auth_from(:user)

      response(200, 'returns impersonation status') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/impersonate/start_impersonating' do
    post('start impersonating') do
      tags 'Impersonate'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :impersonate_params, in: :body, schema: {
        type: :object,
        properties: { id: { type: :integer } }
      }
      rswag_auth_from(:user)

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:impersonate_params) { { id: 0 } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/impersonate/stop_impersonating' do
    post('stop impersonating') do
      tags 'Impersonate'
      produces 'application/json'
      rswag_prepare_connection(:user)
      rswag_auth_from(:user)

      response(200, 'stops impersonation') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
