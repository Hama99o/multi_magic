class Api::V1::SafezoneApp::PaymentCardsController < ApplicationController
  before_action :set_payment_card, only: %i[show update destroy]
  before_action :authorize_payment_card, only: %i[show update destroy]

  def index
    payment_cards = current_user.safezone_app_payment_cards.where(status: :published)

    payment_card_index(payment_cards)
  end

  def show
    render json: SafezoneApp::PaymentCardSerializer.render_as_json(@payment_card)
  end

  def create
    payment_card = current_user.safezone_app_payment_cards.new(status: :published,  **payment_card_params)
    authorize payment_card

    if payment_card.save
      render json: SafezoneApp::PaymentCardSerializer.render_as_json(payment_card), status: :created
    else
      render json: payment_card.errors, status: :unprocessable_entity
    end
  end

  def update
    if @payment_card.update(payment_card_params)
      render json: SafezoneApp::PaymentCardSerializer.render_as_json(@payment_card)
    else
      render json: @payment_card.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @payment_card.destroy
    head :no_content
  end

  private

  def payment_card_index(payment_cards)
    payment_cards = payment_cards.search_cards(params[:search]) if params[:search].present?

    paginate_render(
      SafezoneApp::PaymentCardSerializer,
      payment_cards.order(updated_at: :desc),
      per_page: 20,
      extra: {
        root: :payment_cards,
        current_user: current_user
      }
    )
  end

  def set_payment_card
    @payment_card = SafezoneApp::PaymentCard.find(params[:id])
  end

  def authorize_payment_card
    authorize @payment_card
  end

  def payment_card_params
    params.require(:payment_card).permit(:name, :card_number, :card_type, :cvv, :expiry_date, :note)
  end
end
