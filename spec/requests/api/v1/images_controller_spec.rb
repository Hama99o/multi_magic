# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::ImagesController', type: :request do
  path '/api/v1/images' do
    rswag_prepare_connection(:user)

    post('upload image') do
      tags 'Images'
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :file, in: :formData, type: :file
      rswag_auth_from(:user)

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:file) { nil }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
