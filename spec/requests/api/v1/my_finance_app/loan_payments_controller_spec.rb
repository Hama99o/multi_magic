# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::MyFinanceApp::LoanPaymentsController', type: :request do
  path '/api/v1/my_finance_app/loan_payments/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    delete('destroy loan payment') do
      tags 'MyFinanceApp::LoanPayments'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'loan payment deleted') do
        let(:contact) { create(:contact) }
        let(:loan) { create(:loan, user: user, contact: contact) }
        let(:loan_payment_record) { create(:loan_payment, loan: loan) }
        let(:id) { loan_payment_record.id }

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
