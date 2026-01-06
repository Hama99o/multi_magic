class Api::V1::TodoApp::TodosController < ApplicationController
  before_action :set_todo, only: [:show, :update, :destroy, :toggle]
  before_action :set_todo_group, only: [:reorder]

  def index
    todos = current_user.todos.active

    # Filter by group if provided
    todos = todos.where(todo_group_id: params[:todo_group_id]) if params[:todo_group_id].present?

    # Filter by completed status if provided
    todos = todos.where(completed: params[:completed]) if params[:completed].present?

    # Search across todos and their groups if provided
    if params[:search].present?
      search_term = params[:search]
      # Search in todo title/notes OR in group name
      matching_group_ids = current_user.todo_groups.active.search_groups(search_term).pluck(:id)
      todos = todos.where(
        'todo_app_todos.id IN (?) OR todo_app_todos.todo_group_id IN (?)',
        current_user.todos.active.search_todos(search_term).pluck(:id),
        matching_group_ids
      )
    end

    todos = todos.order(created_at: :desc)

    render json: {
      todos: TodoApp::TodoSerializer.render_as_json(todos)
    }, status: :ok
  end

  def show
    render json: {
      todo: TodoApp::TodoSerializer.render_as_json(@todo)
    }, status: :ok
  end

  def create
    todo_group = current_user.todo_groups.active.find(params[:todo_group_id])
    todo = todo_group.todos.build(todo_params.merge(user: current_user))

    if todo.save
      render json: {
        todo: TodoApp::TodoSerializer.render_as_json(todo)
      }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo.update(todo_params)
      render json: {
        todo: TodoApp::TodoSerializer.render_as_json(@todo)
      }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def toggle
    @todo.update(completed: !@todo.completed)
    render json: {
      todo: TodoApp::TodoSerializer.render_as_json(@todo)
    }, status: :ok
  end

  def destroy
    @todo.destroy
    render json: { message: 'Todo deleted successfully' }, status: :ok
  end

  def reorder
    todo_ids = params[:todo_ids]
    return render json: { error: 'No todo_ids provided' }, status: :bad_request if todo_ids.blank?

    ActiveRecord::Base.transaction do
      todo_ids.each_with_index do |id, index|
        @todo_group.todos.find(id).update!(position: index + 1)
      end
    end

    render json: { message: 'Todos reordered successfully' }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  private

  def set_todo_group
    @todo_group = current_user.todo_groups.active.find(params[:todo_group_id])
  end

  def set_todo
    @todo = current_user.todos.active.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :notes, :completed, :position, :todo_group_id)
  end
end
