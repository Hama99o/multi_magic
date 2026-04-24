# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::ConversationsController', type: :request do
  path '/api/v1/conversations' do
    rswag_prepare_connection(:user)

    get('list conversations') do
      tags 'Conversations'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns conversations') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create conversation') do
      tags 'Conversations'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :conversation_params, in: :body, schema: {
        type: :object,
        properties: { recipient_id: { type: :integer } }
      }
      rswag_auth_from(:user)

      response(200, 'conversation created') do
        let(:other_user) { create(:user) }
        let(:conversation_params) { { user_id: other_user.id } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:conversation_params) { { user_id: 0 } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/conversations/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show conversation') do
      tags 'Conversations'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns conversation') do
        let(:other_user) { create(:user) }
        let(:conversation) { Conversation.create_one_to_one(user.id, other_user.id) }
        let(:id) { conversation.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
