# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::BlogApp::Articles::CommentsController', type: :request do
  path '/api/v1/blog_app/articles/{article_id}/comments' do
    parameter name: :article_id, in: :path, type: :integer

    get('list comments (public)') do
      tags 'BlogApp::Comments'
      produces 'application/json'

      response(200, 'returns comments') do
        let(:article) { create(:blog_app_article, status: :published) }
        let(:article_id) { article.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end
    end

    post('create comment') do
      tags 'BlogApp::Comments'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :comment_params, in: :body, schema: {
        type: :object,
        properties: { body: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'comment created') do
        let(:article) { create(:blog_app_article, status: :published) }
        let(:article_id) { article.id }
        let(:comment_params) { { body: 'Great article!' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:article_id) { 0 }
        let(:comment_params) { { body: 'Great article!' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/blog_app/articles/{article_id}/comments/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :article_id, in: :path, type: :integer
    parameter name: :id, in: :path, type: :integer

    patch('update comment') do
      tags 'BlogApp::Comments'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :comment_params, in: :body, schema: {
        type: :object,
        properties: { body: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'comment updated') do
        let(:article) { create(:blog_app_article, status: :published) }
        let(:article_id) { article.id }
        let(:comment_record) { create(:comment, user: user, commentable: article) }
        let(:id) { comment_record.id }
        let(:comment_params) { { body: 'Updated comment' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:article_id) { 0 }
        let(:id) { 0 }
        let(:comment_params) { { body: 'Updated comment' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy comment') do
      tags 'BlogApp::Comments'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'comment deleted') do
        let(:article) { create(:blog_app_article, status: :published) }
        let(:article_id) { article.id }
        let(:comment_record) { create(:comment, user: user, commentable: article) }
        let(:id) { comment_record.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:article_id) { 0 }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
