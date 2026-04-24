# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::BlogApp::ArticlesController', type: :request do
  path '/api/v1/blog_app/articles' do
    get('list articles (public)') do
      tags 'BlogApp::Articles'
      produces 'application/json'

      response(200, 'returns published articles') do
        run_test! { expect(response).to have_http_status(:ok) }
      end
    end

    post('create article') do
      tags 'BlogApp::Articles'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :article_params, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string }
        }
      }
      rswag_auth_from(:user)

      response(200, 'article created') do
        let(:article_params) { { title: 'My Article', description: 'Content here' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:article_params) { { title: 'My Article' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/blog_app/articles/{id}' do
    parameter name: :id, in: :path, type: :integer

    get('show article (public)') do
      tags 'BlogApp::Articles'
      produces 'application/json'

      response(200, 'returns article') do
        let(:article) { create(:blog_app_article, status: :published) }
        let(:id) { article.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end
    end

    patch('update article') do
      tags 'BlogApp::Articles'
      consumes 'application/json'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :article_params, in: :body, schema: {
        type: :object,
        properties: { title: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'article updated') do
        let(:article) { create(:blog_app_article, user: user) }
        let(:id) { article.id }
        let(:article_params) { { title: 'Updated Title' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:article_params) { { title: 'Updated Title' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy article') do
      tags 'BlogApp::Articles'
      produces 'application/json'
      rswag_prepare_connection(:user)
      rswag_auth_from(:user)

      response(200, 'article deleted') do
        let(:article) { create(:blog_app_article, user: user) }
        let(:id) { article.id }

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
