class Api::V1::SafezoneApp::CardsController < ApplicationController
  before_action :set_card, only: %i[show update destroy]
  before_action :authorize_card, only: %i[show update destroy]

  def index
    cards = current_user.safezone_app_cards

    card_index(cards)
  end

  def show
    render json: SafezoneApp::CardSerializer.render_as_json(@card)
  end

  def create
    card = current_user.safezone_app_cards.new(card_params)
    authorize card

    if card.save
      render json: SafezoneApp::CardSerializer.render_as_json(card), status: :created
    else
      render json: card.errors, status: :unprocessable_entity
    end
  end

  def update
    if @card.update(card_params)
      render json: SafezoneApp::CardSerializer.render_as_json(@card)
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    head :no_content
  end

  private

  def card_index(cards)
    cards = cards.search_cards(params[:search]) if params[:search].present?

    paginate_render(
      SafezoneApp::CardSerializer,
      cards.order(updated_at: :desc),
      per_page: 20,
      extra: {
        root: :cards,
        current_user: current_user
      }
    )
  end

  def set_card
    @card = SafezoneApp::Card.find(params[:id])
  end

  def authorize_card
    authorize @card
  end

  def card_params
    params.require(:card).permit(:name, :card_type, :identifier, :expiry_date, :note)
  end
end
