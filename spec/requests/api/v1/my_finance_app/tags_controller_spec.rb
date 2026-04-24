# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::MyFinanceApp::TagsController', type: :request do
  path '/api/v1/my_finance_app/tags' do
    rswag_prepare_connection(:user)

    get('list finance tags') do
      tags 'MyFinanceApp::Tags'
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

    post('create finance tag') do
      tags 'MyFinanceApp::Tags'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :tag_params, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'tag created') do
        let(:tag_params) { { tag: { name: 'Food' } } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:tag_params) { { tag: { name: 'Food' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/my_finance_app/tags/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    delete('destroy finance tag') do
      tags 'MyFinanceApp::Tags'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'tag deleted') do
        let(:fin_tag) { create(:my_finance_app_tag, user_id: user.id) }
        let(:id) { fin_tag.id }

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
