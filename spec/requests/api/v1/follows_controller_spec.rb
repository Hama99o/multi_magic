# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::FollowsController', type: :request do
  path '/api/v1/follows/follow' do
    post('follow a user') do
      tags 'Follows'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :follow_params, in: :body, schema: {
        type: :object,
        properties: { followed_id: { type: :integer } }
      }
      rswag_auth_from(:user)

      response(200, 'user followed') do
        let(:other_user) { create(:user) }
        let(:follow_params) { { followed_id: other_user.id } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:follow_params) { { followed_id: 0 } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/follows/unfollow' do
    post('unfollow a user') do
      tags 'Follows'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :follow_params, in: :body, schema: {
        type: :object,
        properties: { followed_id: { type: :integer } }
      }
      rswag_auth_from(:user)

      response(200, 'user unfollowed') do
        let(:other_user) { create(:user) }
        let!(:follow_record) { create(:follow, follower: user, followed: other_user) }
        let(:follow_params) { { followed_id: other_user.id } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:follow_params) { { followed_id: 0 } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
