# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::MyFinanceApp::LoansController', type: :request do
  path '/api/v1/my_finance_app/loans' do
    rswag_prepare_connection(:user)

    get('list loans') do
      tags 'MyFinanceApp::Loans'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns loans') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create loan') do
      tags 'MyFinanceApp::Loans'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :loan_params, in: :body, schema: {
        type: :object,
        properties: {
          description: { type: :string },
          amount: { type: :number },
          loan_type: { type: :integer },
          contact_name: { type: :string }
        }
      }
      rswag_auth_from(:user)

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:loan_params) { { description: 'Car loan' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/my_finance_app/loans/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show loan') do
      tags 'MyFinanceApp::Loans'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns loan') do
        let(:contact) { create(:contact) }
        let(:loan) { create(:loan, user: user, contact: contact) }
        let(:id) { loan.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update loan') do
      tags 'MyFinanceApp::Loans'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :loan_params, in: :body, schema: {
        type: :object,
        properties: { description: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'loan updated') do
        let(:contact) { create(:contact) }
        let(:loan) { create(:loan, user: user, contact: contact) }
        let(:id) { loan.id }
        let(:loan_params) { { description: 'Updated' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:loan_params) { { description: 'Updated' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy loan') do
      tags 'MyFinanceApp::Loans'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'loan deleted') do
        let(:contact) { create(:contact) }
        let(:loan) { create(:loan, user: user, contact: contact) }
        let(:id) { loan.id }

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
