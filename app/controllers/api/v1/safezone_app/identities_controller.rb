class Api::V1::SafezoneApp::IdentitiesController < ApplicationController
  before_action :set_identity, only: %i[show update destroy]
  before_action :authorize_identity, only: %i[show update destroy]

  def index
    identities = current_user.safezone_app_identities

    identity_index(identities)
  end

  def show
    render json: SafezoneApp::IdentitySerializer.render_as_json(@identity)
  end

  def create
    identity = current_user.safezone_app_identities.new(identity_params)
    authorize identity

    if identity.save
      render json: SafezoneApp::IdentitySerializer.render_as_json(identity), status: :created
    else
      render json: identity.errors, status: :unprocessable_entity
    end
  end

  def update
    if @identity.update(identity_params)
      render json: SafezoneApp::IdentitySerializer.render_as_json(@identity)
    else
      render json: @identity.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @identity.destroy
    head :no_content
  end

  private

  def identity_index(identities)
    identities = identities.search_identities(params[:search]) if params[:search].present?

    paginate_render(
      SafezoneApp::IdentitySerializer,
      identities.order(updated_at: :desc),
      per_page: 20,
      extra: {
        root: :identities,
        current_user: current_user
      }
    )
  end

  def set_identity
    @identity = SafezoneApp::Identity.find(params[:id])
  end

  def authorize_identity
    authorize @identity
  end

  def identity_params
    params.require(:identity).permit(:type, :document_number, :issued_at, :expires_at, :image, :note)
  end
end
