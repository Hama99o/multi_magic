# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::BlogApp::Articles::ReactionsController', type: :request do
  path '/api/v1/blog_app/articles/{article_id}/reactions' do
    rswag_prepare_connection(:user)
    parameter name: :article_id, in: :path, type: :integer

    get('list reactions') do
      tags 'BlogApp::Reactions'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns reactions') do
        let(:article) { create(:blog_app_article, user: user) }
        let(:article_id) { article.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:article_id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create reaction') do
      tags 'BlogApp::Reactions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :reaction_params, in: :body, schema: {
        type: :object,
        properties: { reaction_type: { type: :integer } }
      }
      rswag_auth_from(:user)

      response(201, 'reaction created') do
        let(:article) { create(:blog_app_article, user: user) }
        let(:article_id) { article.id }
        let(:reaction_params) { { reaction_type: 1 } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:article_id) { 0 }
        let(:reaction_params) { { reaction_type: 1 } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy reaction') do
      tags 'BlogApp::Reactions'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'reaction deleted') do
        let(:article) { create(:blog_app_article, user: user) }
        let(:article_id) { article.id }
        let!(:reaction_record) { create(:reaction, user: user, reactionable: article) }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:article_id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
