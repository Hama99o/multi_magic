# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::TodoApp::TodoGroupsController', type: :request do
  path '/api/v1/todo_app/todo_groups' do
    rswag_prepare_connection(:user)

    get('list todo groups') do
      tags 'TodoApp::TodoGroups'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns todo groups') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create todo group') do
      tags 'TodoApp::TodoGroups'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :group_params, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(201, 'todo group created') do
        let(:group_params) { { name: 'My Group' } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:group_params) { { name: 'My Group' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/todo_app/todo_groups/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show todo group') do
      tags 'TodoApp::TodoGroups'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns todo group') do
        let(:todo_group_record) { create(:todo_group, user: user) }
        let(:id) { todo_group_record.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update todo group') do
      tags 'TodoApp::TodoGroups'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :group_params, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'todo group updated') do
        let(:todo_group_record) { create(:todo_group, user: user) }
        let(:id) { todo_group_record.id }
        let(:group_params) { { name: 'Updated Group' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:group_params) { { name: 'Updated Group' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy todo group') do
      tags 'TodoApp::TodoGroups'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'todo group deleted') do
        let(:todo_group_record) { create(:todo_group, user: user) }
        let(:id) { todo_group_record.id }

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
