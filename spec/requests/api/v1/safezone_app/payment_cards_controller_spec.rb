# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::SafezoneApp::PaymentCardsController', type: :request do
  path '/api/v1/safezone_app/payment_cards' do
    rswag_prepare_connection(:user)

    get('list payment cards') do
      tags 'SafezoneApp::PaymentCards'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns payment cards') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create payment card') do
      tags 'SafezoneApp::PaymentCards'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :card_params, in: :body, schema: {
        type: :object,
        properties: {
          card_number: { type: :string },
          holder_name: { type: :string }
        }
      }
      rswag_auth_from(:user)

      response(201, 'payment card created') do
        let(:card_params) { { payment_card: { name: 'My Card', card_number: '4111111111111111' } } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:card_params) { { payment_card: { card_number: '4111111111111111' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/safezone_app/payment_cards/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show payment card') do
      tags 'SafezoneApp::PaymentCards'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns payment card') do
        let(:card) { create(:safezone_app_payment_card, owner: user) }
        let(:id) { card.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update payment card') do
      tags 'SafezoneApp::PaymentCards'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :card_params, in: :body, schema: {
        type: :object,
        properties: { holder_name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'payment card updated') do
        let(:card) { create(:safezone_app_payment_card, owner: user) }
        let(:id) { card.id }
        let(:card_params) { { payment_card: { name: 'Jane Doe' } } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:card_params) { { payment_card: { name: 'Jane Doe' } } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy payment card') do
      tags 'SafezoneApp::PaymentCards'
      produces 'application/json'
      rswag_auth_from(:user)

      response(204, 'payment card deleted') do
        let(:card) { create(:safezone_app_payment_card, owner: user) }
        let(:id) { card.id }

        run_test! { expect(response).to have_http_status(:no_content) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
