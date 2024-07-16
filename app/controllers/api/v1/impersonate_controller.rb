class Api::V1::ImpersonateController < ApplicationController

  def start_impersonating
    user = User.find(params[:id])
    impersonate_user(user)

    render json: { user: UserSerializer.render_as_json(user, view: :private) }, status: :ok
  end

  def stop_impersonating
    stop_impersonating_user

    render json: { user: UserSerializer.render_as_json(current_user, view: :private) }, status: :ok
  end

  def is_impersonating
    render json: { isImpersonating: current_user['id'] != true_user['id'] }
  end
end
