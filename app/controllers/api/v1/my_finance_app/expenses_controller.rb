class Api::V1::MyFinanceApp::ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :update, :destroy, :destroy_permanently, :restore]

  # GET /expenses
  def index
    expenses = policy_scope(current_user.expenses.where(status: :published))
    expense_index(expenses)
  end

  # GET /expenses/trashes
  def trashes
    expenses = policy_scope(current_user.expenses.where(status: :trashed))
    expense_index(expenses)
  end

  # GET /expenses/:id
  def show
    render json: { expense: MyFinanceApp::ExpenseSerializer.render_as_json(@expense)}
  end

  # POST /expenses
  def create
    @expense = MyFinanceApp::Expense.new(expense_params.merge(status: :published, user: current_user))

    if authorize(@expense).save
      render json: { expense: MyFinanceApp::ExpenseSerializer.render_as_json(@expense)}, status: :created
    else
      render json: @expense.errors, status: :unprocessable_entity
    end
  end

  # PUT /expenses/:id
  def update
    if authorize(@expense).update(expense_params)
      render json: { expense: MyFinanceApp::ExpenseSerializer.render_as_json(@expense)}
    else
      render json: @expense.errors, status: :unprocessable_entity
    end
  end

  def pie_chart_data_by_subcategories
    # Fetch the selected tag
    selected_tag = MyFinanceApp::Tag.find_by(id: params[:tag_id])

    # Ensure the tag exists
    unless selected_tag
      return render json: { error: 'Tag not found' }, status: :not_found
    end

    # Fetch expenses for the selected tag and group by subcategory
    expenses = policy_scope(current_user.expenses)
                .where(status: :published, tag_id: selected_tag.id)
                .joins(:subcategory)
                .group('tags.name')
                .sum(:amount)


    # Format the data for the pie chart
    chart_data = expenses.map do |subcategory, amount|
      { category: subcategory, amount: amount }
    end

    # Calculate total spend for the selected tag
    total_spend = current_user.expenses.where(status: :published, tag_id: selected_tag.id).group(:currency).sum(:amount)

    render json: { chart_data: chart_data, total_spend: total_spend }
  end

  def pie_chart_data_by_tag
    expenses = policy_scope(current_user.expenses).where(status: :published).joins(:tag).group('tags.name').sum(:amount)

    chart_data = expenses.map do |category, amount|
      { category: category, amount: amount }
    end

    chart_data
    render json: { chart_data:, total_spend: current_user.expenses.where(status: :published)&.group(:currency).sum(:amount) }
  end

  def total_expenses_last_years_or_months
    expenses = policy_scope(MyFinanceApp::Expense.where(status: :published))
    if params[:chart_type] == 'years'
      expenses = expenses.total_amount_last_years(current_user)
    else
      expenses = expenses.total_amount_last_months(current_user)
    end

    # Formatting the data for the chart
    chart_data = {
      labels: expenses.keys.map { |year| year.to_s },
      data: expenses.values
    }

    render json: chart_data
  end

  def create_tag
    tag = MyFinanceApp::Tag.create(name: params[:text])

    if tag
      render json: {
        tag: TagSerializer.render_as_json(tag, current_user: current_user)
      }, status: :ok
    else
      render json: { error: "Failed to create tag" }, status: :unprocessable_entity
    end
  end

  # DELETE /expenses/:id
  def destroy
    if authorize(@expense).update(status: :trashed, deleted_at: Time.now)
      render json: @expense
    else
      render_unprocessable_entity(@expense)
    end
  end

  def destroy_permanently
    if authorize(@expense).delete
      render json: { expense: @expense }, status: :ok
    else
      render_unprocessable_entity(@expense)
    end
  end

  def restore
    if authorize(@expense).update(status: :published, deleted_at: nil)
      render json: @expense
    else
      render_unprocessable_entity(@expense)
    end
  end

  # GET /expenses/tags
  def tags
    tags = MyFinanceApp::Tag.all
    tags = tags.search_tags(params[:search]) if params[:search].present?

    paginate_render(
      TagSerializer,
      tags,
      per_page: 50,
      extra: {
        root: :tags,
        current_user: current_user
      }
    )
  end

  private

  def expense_index(expenses)
    expenses = expenses.search_expenses(params[:search]) if params[:search].present?

    paginate_render(
      MyFinanceApp::ExpenseSerializer,
      # policy_scope(expenses.order(updated_at: :desc)),
      expenses.order(updated_at: :desc),
      per_page: 5,
      extra: {
        root: :expenses,
        current_user: current_user
      }
    )
  end


  # Find expense by ID
  def set_expense
    @expense = MyFinanceApp::Expense.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Expense not found' }, status: :not_found
  end

  # Only allow a list of trusted parameters through
  def expense_params
    params.require(:expense).permit(:user_id, :item, :amount, :description, :tag_id, :currency, :subcategory_id, :spent_at)
  end
end
