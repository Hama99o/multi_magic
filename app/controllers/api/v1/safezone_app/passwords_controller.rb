class Api::V1::SafezoneApp::PasswordsController < ApplicationController
  before_action :set_passwords, only: %i[show update destroy]
  before_action :authorize_passwords, only: %i[show update destroy]

  def index
    passwords = current_user.safezone_app_passwords.order(updated_at: :desc)

    password_index(passwords)
  end

  def show
    render json: SafezoneApp::PasswordSerializer.render_as_json(@password)
  end

  def create
    password = current_user.safezone_app_passwords.new(password_params)
    authorize password

    if password.save
      render json: SafezoneApp::PasswordSerializer.render_as_json(password), status: :created
    else
      render json: password.errors, status: :unprocessable_entity
    end
  end

  def update
    if @password.update(password_params)
      render json: SafezoneApp::PasswordSerializer.render_as_json(@password)
    else
      render json: @password.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @password.destroy
    head :no_content
  end

  private

  def password_index(passwords)
    passwords = passwords.search_passwords(params[:search]) if params[:search].present?

    paginate_render(
      SafezoneApp::PasswordSerializer,
      passwords,
      per_page: 20,
      extra: {
        root: :passwords,
        current_user: current_user
      }
    )
  end

  def set_passwords
    @password = SafezoneApp::Password.find(params[:id])
  end

  def authorize_passwords
    authorize @password
  end

  def password_params
    params.require(:password).permit(:email, :username, :password, :link, :password, :title)
  end
end




