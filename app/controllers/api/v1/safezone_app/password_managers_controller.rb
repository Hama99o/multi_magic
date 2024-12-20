class Api::V1::SafezoneApp::PasswordManagersController < ApplicationController
  before_action :set_password_manager, only: %i[show update destroy]
  before_action :authorize_password_manager, only: %i[show update destroy]

  def index
    password_managers = current_user.safezone_app_password_managers
    render json: SafezoneApp::PasswordManagerSerializer.render_as_json(password_managers)
  end

  def show
    render json: SafezoneApp::PasswordManagerSerializer.render_as_json(@password_manager)
  end

  def create
    password_manager = current_user.safezone_app_password_managers.new(password_manager_params)
    authorize password_manager

    if password_manager.save
      render json: SafezoneApp::PasswordManagerSerializer.render_as_json(password_manager), status: :created
    else
      render json: password_manager.errors, status: :unprocessable_entity
    end
  end

  def update
    if @password_manager.update(password_manager_params)
      render json: SafezoneApp::PasswordManagerSerializer.render_as_json(@password_manager)
    else
      render json: @password_manager.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @password_manager.destroy
    head :no_content
  end

  private

  def set_password_manager
    @password_manager = SafezoneApp::PasswordManager.find(params[:id])
  end

  def authorize_password_manager
    authorize @password_manager
  end

  def password_manager_params
    params.require(:password_manager).permit(:email, :username, :description, :link, :status, :data)
  end
end




