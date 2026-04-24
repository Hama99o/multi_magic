# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::AiController', type: :request do
  path '/api/v1/ai/show' do
    rswag_prepare_connection(:user)

    post('stream AI response') do
      tags 'AI'
      produces 'text/event-stream'
      parameter name: :prompt, in: :query, type: :string
      rswag_auth_from(:user)

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:prompt) { 'Hello' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
