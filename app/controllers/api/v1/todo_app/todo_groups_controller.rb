class Api::V1::TodoApp::TodoGroupsController < ApplicationController
  before_action :set_todo_group, only: [:show, :update, :destroy]

  def index
    groups = current_user.todo_groups.active
    groups = groups.search_groups(params[:search]) if params[:search].present?

    paginate_render(
      TodoApp::TodoGroupSerializer,
      groups.order(updated_at: :desc),
      per_page: 20,
      root: :todo_groups,
      extra: {
        view: :with_preview_todos
      }
    )
  end

  def show
    render json: {
      todo_group: TodoApp::TodoGroupSerializer.render_as_json(@todo_group, view: :with_todos)
    }, status: :ok
  end

  def create
    todo_group = current_user.todo_groups.build(todo_group_params)

    if todo_group.save
      render json: {
        todo_group: TodoApp::TodoGroupSerializer.render_as_json(todo_group)
      }, status: :created
    else
      render json: { errors: todo_group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo_group.update(todo_group_params)
      render json: {
        todo_group: TodoApp::TodoGroupSerializer.render_as_json(@todo_group)
      }, status: :ok
    else
      render json: { errors: @todo_group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_group.destroy
    render json: { message: 'Todo group deleted successfully' }, status: :ok
  end

  private

  def set_todo_group
    @todo_group = current_user.todo_groups.active.find(params[:id])
  end

  def todo_group_params
    params.require(:todo_group).permit(:name, :position)
  end
end
