# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::BlocksController', type: :request do
  path '/api/v1/blocks/block' do
    post('block a user') do
      tags 'Blocks'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :block_params, in: :body, schema: {
        type: :object,
        properties: { blocked_id: { type: :integer } }
      }
      rswag_auth_from(:user)

      response(200, 'user blocked') do
        let(:other_user) { create(:user) }
        let(:block_params) { { blocked_id: other_user.id } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:block_params) { { blocked_id: 0 } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/blocks/unblock' do
    post('unblock a user') do
      tags 'Blocks'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :block_params, in: :body, schema: {
        type: :object,
        properties: { blocked_id: { type: :integer } }
      }
      rswag_auth_from(:user)

      response(200, 'user unblocked') do
        let(:other_user) { create(:user) }
        let!(:block_record) { create(:block, blocker: user, blocked: other_user) }
        let(:block_params) { { blocked_id: other_user.id } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:block_params) { { blocked_id: 0 } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
