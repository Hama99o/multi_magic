
# app/controllers/loan_payments_controller.rb
class Api::V1::MyFinanceApp::LoanPaymentsController < ApplicationController
  before_action :set_loan_payment, only: [:destroy]

  def destroy
    @loan_payment.destroy
    render json: { message: 'Payment deleted successfully' }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_loan_payment
    @loan_payment = MyFinanceApp::LoanPayment.find(params[:id])
  end
end