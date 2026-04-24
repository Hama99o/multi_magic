# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Conversations::MessagesController', type: :request do
  path '/api/v1/conversations/{conversation_id}/messages' do
    rswag_prepare_connection(:user)
    parameter name: :conversation_id, in: :path, type: :integer

    get('list messages') do
      tags 'Conversations::Messages'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns messages') do
        let(:other_user) { create(:user) }
        let(:conversation) { Conversation.create_one_to_one(user.id, other_user.id) }
        let(:conversation_id) { conversation.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:conversation_id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create message') do
      tags 'Conversations::Messages'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :message_params, in: :body, schema: {
        type: :object,
        properties: { body: { type: :string } }
      }
      rswag_auth_from(:user)

      response(201, 'message created') do
        let(:other_user) { create(:user) }
        let(:conversation) { Conversation.create_one_to_one(user.id, other_user.id) }
        let(:conversation_id) { conversation.id }
        let(:message_params) { { body: 'Hello!' } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:conversation_id) { 0 }
        let(:message_params) { { body: 'Hello!' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
