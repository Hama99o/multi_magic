class Api::V1::UsersController < ApplicationController
  # include Pagy::Backend
  # before_action :authenticate_user!, except: [:reset_password]

  before_action :user, only: [:show, :update, :destroy, :change_password, :following, :followers]
  before_action :users, only: [:index, :activated_users]
  skip_before_action :authenticate_user!, only: [:reset_password, :reset_password_confirmation]

  def index
    if true_user && true_user.access_level == 'super_admin'
      @users = @users.search_users(params[:search]) if params[:search].present?
      paginate_render(UserSerializer,(@users), extra:{ view: :private })
    else
      render json: { message: "Access Denied: Insufficient Permissions" }, status: :unprocessable_entity
    end
  end

  def global_users
    users = User.all.where.not(id: current_user.id)
    users = users.search_users(params[:search]) if params[:search].present?

    paginate_render(UserSerializer, users, extra: { view: :public })
  end


  def following
    following = @user.following
    paginate_render(UserSerializer, following, extra: { view: :public })
  end

  def followers
    followers = @user.followers
    paginate_render(UserSerializer, followers, extra: { view: :public })
  end

  def connected_user
    render json: UserSerializer.render_as_json(current_user, root: "user", view: :me, true_user:),
           status: :ok
  end

  def show
    render json: {
      user: UserSerializer.render_as_json((@user), view: :private, current_user:)
    }, status: :ok
  end

  def update
    if @user.update(**user_params)
      render json: { user: UserSerializer.render_as_hash(authorize(@user), view: :private) }, status: :ok
    else
      render json: @user.errors.messages, status: :unprocessable_entity
    end
  end

  def reset_password
    user = User.where(status: :active).find_by(email: params.require(:email).strip.downcase)
    if user.present?
      user.reset_password!
      head :ok
    else
      render json: { message: "Email does not exist" }, status: :unprocessable_entity
    end
  end

  def change_password
    if authorize(@user).valid_password?(params[:current_password])
      if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
        # sign_out_other_devices if params[:logout_other_devices]

        render json: {
          message: 'Password changed successfully',
          user: UserSerializer.render_as_json(@user, view: :private),
          }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Current password is incorrect' }, status: :unauthorized
    end
  end

  def reset_password_confirmation
    @token = params.require(:token)
    @user = User.find_by(reset_password_token: @token)
    raise Pundit::NotAuthorizedError, "token invalid" if @user.nil?
    @password = params.require(:password)

    @user.update(password: @password, reset_password_token: nil)
  end

  def destroy_avatar
    @user = authorize(User.find(params[:id]))

    if params[:image_type_name] && @user&.send(params[:image_type_name])&.attached?
      @user&.send(params[:image_type_name])&.purge # This deletes the attachment and its blob
      render json: { user: UserSerializer.render_as_json(@user, view: :private), message: 'Image deleted successfully' }, status: :ok
    else
      render json: { error: 'No avatar attached' }, status: :unprocessable_entity
    end
  end

  # def create
  #   user = User.create(**user_params)

  #   if user
  #     render json: { user: authorize(user) }, status: :ok
  #   else
  #     render json: user.errors.messages, status: :unprocessable_entity
  #   end
  # end

  # def destroy
  #   if @user.delete
  #     render json: { user: authorize(@user) }, status: :ok
  #   else
  #     render json: @user.errors.messages, status: :unprocessable_entity
  #   end
  # end

  # def activated_users
  #   @users = @users.search_name(params[:search]) if params[:search].present?
  #   pagy_blue(UserSerializer, policy_scope(@users.where(on_off: 'On').order(created_at: :desc)), extra: { view: :all })
  # end

  # def reset_password
  #   @user = User.find_by("LOWER(email) = ?", params.require(:email).strip.downcase)
  #   authorize(@user).reset_password! if @user

  #   head :ok
  # end

  # private

  def user
    @user = User.find(params.require(:id))
  end

  def users
    @users ||= User.all
  end

  def user_params
    params.permit(
      :firstname,
      :lastname,
      :email,
      :birth_date,
      :phone_number,
      :gender,
      :language,
      :access_level,
      :note_index_type,
      :photo,
      :cover_photo,
      :country_code,
      :theme,
      :about,
      :username
    )
  end
end
