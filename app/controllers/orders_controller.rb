class OrdersController < ApplicationController
  before_action :set_order, except: [:index, :create, :create_suborder, :new]
  helper_method :sort


  def index
    if params[:search].present?
      orders = Order.includes(:invoice, :team).search_for(params[:search])
    else
      orders = Order.includes(:invoice, :team).all
    end

    @articles = orders.order(sort)
    paginate json: @articles, per_page: params[:limit]
  end

  def show
    @order = Order.includes(:invoice).find(params[:id])
    render json: @order, serializer: OrderShowSerializer
  end

  def edit
  end

  def create
    @order = Order.new(order_params)
    if params[:team].present? && params[:team][:id]
      @order.team_id = params[:team][:id]
      if @order.save
        render json: @order, serializer: AfterCreationSerializer, status: 201
      else
        render json: error_builder(@order), status: :unprocessable_entity
      end
    else
      render json: { errors: ['Team value is missing'] }, status: :unprocessable_entity
    end
  end

  def update
    if params[:team].present?
      new_params = order_params.merge(:team_id => params[:team][:id])
    else
      new_params = order_params
    end
    if @order.update(new_params)
      render json: @order, serializer: AfterCreationSerializer, status: 200
    else
      render json: error_builder(@order), status: :unprocessable_entity
    end
  end

  def destroy
    if @order.destroy
      render json: {}, status: 200
    else
      render json: error_builder(@order), status: :unprocessable_entity
    end
  end

  def set_invoice
    @order.invoice = Invoice.find(params[:invoice_id])
    if @order.save
      render json: {}, status: 200
    else
      render json: error_builder(@order), status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Invoice does not exist'] },
    status: :unprocessable_entity
  end

  def delete_invoice
    @order.invoice_id = nil
    if @order.save
      render json: {}, status: 202
    else
      render json: error_builder(@order), status: :unprocessable_entity
    end
  end

  def suborders
    @suborders = @order.sub_orders.all
    render json: @suborders
  end

  def create_suborder
    @order = Order.new(order_params)
    unless params[:allocatable_budget]
      render json: { errors: ['Allocatable budget is missing'] }, status: :unprocessable_entity
      return 0
    end
    unless params[:team].present? && params[:team][:id].present?
      render json: { errors: ['Team value is missing'] }, status: :unprocessable_entity
      return 0
    end
    @order.team_id = params[:team][:id]
    @order.invoiced_budget = order_params[:allocatable_budget]
    @order.parent = Order.find(params[:order_id])
    if @order.save
      render json: @order, serializer: AfterCreationSerializer, status: 201
    else
      render json: error_builder(@order), status: :unprocessable_entity
    end
  end

  def new
    @order = Order.new
    render json: @order, serializer: OrderShowSerializer
  end

  def set_completed
    if @order.completed == true
      return render json: { errors: ['Can not complete already completed order'] }, status: :unprocessable_entity # FIXME
    end
    if @order.update_attributes(completed: true)
      render json: @order, serializer: AfterCreationSerializer, status: 200
    else
      render json: error_builder(@order), status: :unprocessable_entity
    end
  end

  def remove_completed
    if @order.completed == false
      return render json: { errors: ['Can not un-complete order, that is not completed'] }, status: :unprocessable_entity # FIXME
    end
    if @order.update_attributes(completed: false)
      render json: @order, serializer: AfterCreationSerializer, status: 200
    else
      render json: error_builder(@order), status: :unprocessable_entity
    end
  end

  private

  def set_order
    if params[:order_id].present?
      @order = Order.includes(:team, :invoice).find(params[:order_id])
    else
      @order = Order.includes(:team, :invoice).find(params[:id])
    end
  end

  def order_params
    params.permit(:name,
    :description,
    :team,
    :invoiced_budget,
    :allocatable_budget,
    :invoice_id,
    :parent_id)
  end
end
