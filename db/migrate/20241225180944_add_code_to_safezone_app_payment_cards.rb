class AddCodeToSafezoneAppPaymentCards < ActiveRecord::Migration[7.0]
  def change
    add_column :safezone_app_payment_cards, :code, :string
  end
end
