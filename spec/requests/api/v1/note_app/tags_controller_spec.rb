# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::NoteApp::TagsController', type: :request do
  path '/api/v1/note_app/tags' do
    rswag_prepare_connection(:user)

    get('list note tags') do
      tags 'NoteApp::Tags'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns tags') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create note tag') do
      tags 'NoteApp::Tags'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :tag_params, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'tag created') do
        let(:tag_params) { { tag: { name: 'Work' } } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:tag_params) { { tag: { name: 'Work' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/note_app/tags/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    patch('update note tag') do
      tags 'NoteApp::Tags'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :tag_params, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'tag updated') do
        let(:note_tag) { create(:note_tag, user: user, position: 1) }
        let(:id) { note_tag.id }
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

    delete('destroy note tag') do
      tags 'NoteApp::Tags'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'tag deleted') do
        let(:note_tag) { create(:note_tag, user: user, position: 1) }
        let(:id) { note_tag.id }

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
