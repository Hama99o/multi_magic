# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::NoteApp::NotesController', type: :request do
  path '/api/v1/note_app/notes' do
    rswag_prepare_connection(:user)

    get('list notes') do
      tags 'NoteApp::Notes'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns notes') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create note') do
      tags 'NoteApp::Notes'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        }
      }
      rswag_auth_from(:user)

      response(200, 'note created') do
        let(:note_params) { { title: 'My Note', content: 'Content here' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:note_params) { { title: 'My Note' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/note_app/notes/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show note') do
      tags 'NoteApp::Notes'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns note') do
        let(:note) { create(:note, owner: user) }
        let(:id) { note.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update note') do
      tags 'NoteApp::Notes'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: { title: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'note updated') do
        let(:note) { create(:note, owner: user) }
        let(:id) { note.id }
        let(:note_params) { { title: 'Updated Note' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:note_params) { { title: 'Updated' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy note') do
      tags 'NoteApp::Notes'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'note deleted') do
        let(:note) { create(:note, owner: user) }
        let(:id) { note.id }

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
