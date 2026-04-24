# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::BlogApp::TagsController', type: :request do
  path '/api/v1/blog_app/tags' do
    get('list tags (public)') do
      tags 'BlogApp::Tags'
      produces 'application/json'

      response(200, 'returns tags') do
        run_test! { expect(response).to have_http_status(:ok) }
      end
    end

    post('create tag') do
      tags 'BlogApp::Tags'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :tag_params, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'tag created') do
        let(:tag_params) { { tag: { name: 'Ruby' } } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:tag_params) { { tag: { name: 'Ruby' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/blog_app/tags/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    patch('update tag') do
      tags 'BlogApp::Tags'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :tag_params, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'tag updated') do
        let(:blog_tag) { create(:blog_app_tag, user: user) }
        let(:id) { blog_tag.id }
        let(:tag_params) { { tag: { name: 'Updated' } } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:tag_params) { { tag: { name: 'Updated' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy tag') do
      tags 'BlogApp::Tags'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'tag deleted') do
        let(:blog_tag) { create(:blog_app_tag, user: user) }
        let(:id) { blog_tag.id }

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
