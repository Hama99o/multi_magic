# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::ContactApp::ContactsController', type: :request do
  path '/api/v1/contact_app/contacts' do
    rswag_prepare_connection(:user)

    get('list contacts') do
      tags 'ContactApp::Contacts'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns contacts') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create contact') do
      tags 'ContactApp::Contacts'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :contact_params, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          email: { type: :string }
        }
      }
      rswag_auth_from(:user)

      response(201, 'contact created') do
        let(:contact_params) { { first_name: 'John', last_name: 'Doe', email: 'john@example.com' } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:contact_params) { { first_name: 'John' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/contact_app/contacts/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show contact') do
      tags 'ContactApp::Contacts'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns contact') do
        let(:contact_record) { create(:contact_app_contact, user: user) }
        let(:id) { contact_record.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update contact') do
      tags 'ContactApp::Contacts'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :contact_params, in: :body, schema: {
        type: :object,
        properties: { firstname: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'contact updated') do
        let(:contact_record) { create(:contact_app_contact, user: user) }
        let(:id) { contact_record.id }
        let(:contact_params) { { contact: { firstname: 'Updated' } } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:contact_params) { { contact: { firstname: 'Updated' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy contact') do
      tags 'ContactApp::Contacts'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'contact deleted') do
        let(:contact_record) { create(:contact_app_contact, user: user) }
        let(:id) { contact_record.id }

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
