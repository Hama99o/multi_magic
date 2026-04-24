# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::BlogApp::Users::BookmarksController', type: :request do
  path '/api/v1/blog_app/users/bookmarks/articles' do
    rswag_prepare_connection(:user)

    get('list user article bookmarks') do
      tags 'BlogApp::UserBookmarks'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns user bookmarks') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/blog_app/users/bookmarks/articles/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    delete('destroy user bookmark') do
      tags 'BlogApp::UserBookmarks'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'bookmark deleted') do
        let(:article) { create(:blog_app_article, user: user) }
        let(:bookmark_record) { create(:bookmark, user: user, bookmarkable: article) }
        let(:id) { bookmark_record.id }

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
