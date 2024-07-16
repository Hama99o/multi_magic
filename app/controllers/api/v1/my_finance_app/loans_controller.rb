class Api::V1::MyFinanceApp::LoansController < ApplicationController
  before_action :set_loan, only: [:show, :update, :destroy, :destroy_permanently, :restore, :create_payment]

  # GET /loans
  def index
    @loans = policy_scope(current_user.loans.where(status: :unpaid))
    loan_index(@loans)
  end

  def paid
    @loans = policy_scope(current_user.loans.where(status: :paid))
    loan_index(@loans)
  end

  # GET /loans/trashes
  def trashes
    loans = policy_scope(current_user.loans.where(status: :trashed))
    loan_index(loans)
  end

  # GET /loans/:id
  def show
    render json: { loan: MyFinanceApp::LoanSerializer.render_as_json(authorize(@loan)) }
  end

  # POST /loans
  def create
    @loan = MyFinanceApp::Loan.new(loan_params.merge(user: current_user, status: :unpaid))

    if authorize(@loan).save
      render json: { loan: MyFinanceApp::LoanSerializer.render_as_json(@loan) }, status: :created
    else
      render json: @loan.errors, status: :unprocessable_entity
    end
  end

  def create_payment
    @payment = @loan.loan_payments.new(payment_params)

    if @payment.save
      update_status(@loan)
      render json: { status: 'success', loan: MyFinanceApp::LoanSerializer.render_as_json(@loan) }, status: :ok
    else
      render json: { status: 'error', errors: @payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /loans/:id
  def update
    if authorize(@loan).update(loan_params)
      update_status(@loan)
      render json: { loan: MyFinanceApp::LoanSerializer.render_as_json(@loan) }
    else
      render json: @loan.errors, status: :unprocessable_entity
    end
  end

  # DELETE /loans/:id
  def destroy
    if authorize(@loan).update(status: :trashed, deleted_at: Time.now)
      render json: @loan
    else
      render_unprocessable_entity(@loan)
    end
  end

  def destroy_permanently
    if authorize(@loan).delete
      render json: { loan: @loan }, status: :ok
    else
      render_unprocessable_entity(@loan)
    end
  end

  def restore
    if authorize(@loan).update(status: :unpaid, deleted_at: nil)
      render json: @loan
    else
      render_unprocessable_entity(@loan)
    end
  end

  def pie_chart_data_by_cantact_name
    loans = policy_scope(
      current_user.loans
    ).where(
        status: params.require('status'),
        loan_type: params.require('loan_type')
      ).group('contact_name').sum(:amount)

    chart_data = loans.map do |category, amount|
      { category: category, amount: amount }
    end

    chart_data
    render json: { chart_data:,  total_spend: current_user.loans.where(status: :published)&.sum(:amount)&.round }
  end

  private

  def loan_index(loans)
    loans = loans.search_loans(params[:search]) if params[:search].present?
    loans = loans.where(loan_type: params[:loan_type]) if params[:loan_type] && loan_types.include?(params[:loan_type])

    paginate_render(
      MyFinanceApp::LoanSerializer,
      # policy_scope(loans.order(updated_at: :desc)),
      loans.order(updated_at: :desc),
      per_page: 5,
      extra: {
        root: :loans,
        current_user: current_user
      }
    )
  end

  def loan_types
    ['given', 'taken']
  end

  def update_status(loan)
    if loan.remaining_amount <= 0
      loan.update(status: :paid)
    else
      loan.update(status: :unpaid)
    end
  end

  # Find loan by ID
  def set_loan
    @loan = MyFinanceApp::Loan.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Loan not found' }, status: :not_found
  end

  # Only allow a list of trusted parameters through
  def loan_params
    params.require(:loan).permit(:loan_type, :amount, :due_date, :description, :tag_id, :contact_name, :status)
  end

  def payment_params
    params.require(:loan_payment).permit(:amount, :payment_date)
  end
end
