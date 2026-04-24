# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::TodoApp::TodosController', type: :request do
  path '/api/v1/todo_app/todos' do
    rswag_prepare_connection(:user)

    get('list todos') do
      tags 'TodoApp::Todos'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns todos') do
        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    post('create todo') do
      tags 'TodoApp::Todos'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :todo_params, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          todo_group_id: { type: :integer }
        }
      }
      rswag_auth_from(:user)

      response(201, 'todo created') do
        let(:todo_group_record) { create(:todo_group, user: user) }
        let(:todo_params) { { title: 'Buy milk', todo_group_id: todo_group_record.id } }

        run_test! { expect(response).to have_http_status(:created) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:todo_params) { { title: 'Buy milk' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/todo_app/todos/{id}' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    get('show todo') do
      tags 'TodoApp::Todos'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'returns todo') do
        let(:todo_group_record) { create(:todo_group, user: user) }
        let(:todo_record) { create(:todo, user: user, todo_group: todo_group_record) }
        let(:id) { todo_record.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    patch('update todo') do
      tags 'TodoApp::Todos'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :todo_params, in: :body, schema: {
        type: :object,
        properties: { title: { type: :string } }
      }
      rswag_auth_from(:user)

      response(200, 'todo updated') do
        let(:todo_group_record) { create(:todo_group, user: user) }
        let(:todo_record) { create(:todo, user: user, todo_group: todo_group_record) }
        let(:id) { todo_record.id }
        let(:todo_params) { { title: 'Updated Todo' } }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }
        let(:todo_params) { { title: 'Updated Todo' } }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end

    delete('destroy todo') do
      tags 'TodoApp::Todos'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'todo deleted') do
        let(:todo_group_record) { create(:todo_group, user: user) }
        let(:todo_record) { create(:todo, user: user, todo_group: todo_group_record) }
        let(:id) { todo_record.id }

        run_test! { expect(response).to have_http_status(:ok) }
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid' }
        let(:id) { 0 }

        run_test! { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end

  path '/api/v1/todo_app/todos/{id}/toggle' do
    rswag_prepare_connection(:user)
    parameter name: :id, in: :path, type: :integer

    put('toggle todo') do
      tags 'TodoApp::Todos'
      produces 'application/json'
      rswag_auth_from(:user)

      response(200, 'todo toggled') do
        let(:todo_group_record) { create(:todo_group, user: user) }
        let(:todo_record) { create(:todo, user: user, todo_group: todo_group_record) }
        let(:id) { todo_record.id }

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
