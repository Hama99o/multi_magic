# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  private

  def respond_with(resource, _opts = {})
    render json: UserSerializer.render_as_hash(resource, view: :private)
  end

  def respond_to_on_destroy
    head :no_content
  end
end
