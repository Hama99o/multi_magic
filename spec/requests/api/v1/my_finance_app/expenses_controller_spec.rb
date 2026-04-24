# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::MyFinanceApp::ExpensesController', type: :request do
  path '/api/v1/my_finance_app/expenses' do
    rswag_prepare_connection(:user)

    get('list expenses') do
      tags 'MyFinanceApp::Expenses'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns expenses') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create expense') do
      tags 'MyFinanceApp::Expenses'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :expense_params, in: :body, schema: {
        type: :object,
        properties: {
          item: { type: :string },
          amount: { type: :number },
          description: { type: :string }
        }
      }
      rswag_auth_from(:user)

      response(201, 'expense created') do
        let(:fin_tag) { create(:my_finance_app_tag, user_id: user.id) }
        let(:expense_params) { { expense: { item: 'Coffee', amount: 5.0, tag_id: fin_tag.id } } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:expense_params) { { expense: { item: 'Coffee', amount: 5.0 } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/my_finance_app/expenses/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show expense') do
      tags 'MyFinanceApp::Expenses'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns expense') do
        let(:expense) { create(:expense, user: user) }
        let(:id) { expense.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update expense') do
      tags 'MyFinanceApp::Expenses'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :expense_params, in: :body, schema: {
        type: :object,
        properties: { item: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'expense updated') do
        let(:expense) { create(:expense, user: user) }
        let(:id) { expense.id }
        let(:expense_params) { { item: 'Updated Item' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:expense_params) { { item: 'Updated Item' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy expense') do
      tags 'MyFinanceApp::Expenses'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'expense deleted') do
        let(:expense) { create(:expense, user: user) }
        let(:id) { expense.id }

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
