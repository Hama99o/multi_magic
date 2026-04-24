# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::BlogApp::Articles::BookmarksController', type: :request do
  path '/api/v1/blog_app/articles/{article_id}/bookmarks' do
    parameter name: :article_id, in: :path, type: :integer

    get('list bookmarks (public)') do
      tags 'BlogApp::ArticleBookmarks'
      produces 'application/json'

      response(200, 'returns bookmarks') do
        let(:article) { create(:blog_app_article, status: :published) }
        let(:article_id) { article.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end
    end

    post('create bookmark') do
      tags 'BlogApp::ArticleBookmarks'
      produces 'application/json'
      rswag_prepare_connection(:user)
      parameter name: :bookmark_params, in: :body, schema: { type: :object }
      rswag_auth_from(:user)

      response(201, 'bookmark created') do
        let(:article) { create(:blog_app_article, user: user) }
        let(:article_id) { article.id }
        let(:bookmark_params) { {} }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:article_id) { 0 }
        let(:bookmark_params) { {} }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy bookmark') do
      tags 'BlogApp::ArticleBookmarks'
      produces 'application/json'
      rswag_prepare_connection(:user)
      rswag_auth_from(:user)

      response(200, 'bookmark deleted') do
        let(:article) { create(:blog_app_article, user: user) }
        let(:article_id) { article.id }
        let!(:bookmark_record) { create(:bookmark, user: user, bookmarkable: article) }

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
