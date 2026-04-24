# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::CaptchaController', type: :request do
  path '/api/v1/captcha/generate' do
    get('get captcha') do
      tags 'Captcha'
      produces 'application/json'

      response(200, 'returns captcha') do
        run_test! { expect(response).to have_http_status(:ok) }
      end
    end
  end
end
