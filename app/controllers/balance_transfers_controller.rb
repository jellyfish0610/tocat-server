class BalanceTransfersController < ApplicationController
  def index
    @articles = BalanceTransfer.order(sort)
    if params[:source].present?
      user = User.find_by_login params[:source]
      @articles = @articles.where(source_id: user.payroll_account.id)
    end
    if params[:target].present?
      user = User.find_by_login params[:target]
      @articles = @articles.where(target_id: user.payroll_account.id)
    end
    paginate json: @articles, per_page: params[:limit]
  end

  def show
    @balance_transfer = BalanceTransfer.find(params[:id])
    render json: @balance_transfer, serializer: BtShowSerializer
  end

  def create
    @bt = BalanceTransfer.new(transfer_params)
    if  @bt.save
      @bt.create_activity :create, 
         parameters: transfer_params,
         owner: User.current_user
      render json: @bt, serializer: BtShowSerializer
    else
      render json: error_builder(@bt), status: :unprocessable_entity
    end
  end
  
  private
  def transfer_params
    params.require(:balance_transfer).permit(:total, :target_login, :description, :source_id, :target_id)
  end
end
