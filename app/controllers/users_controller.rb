class UsersController < ApplicationController
  before_action :set_user, except: [:index]

  def index
    @articles = User.search_for(params[:search]).order(sort)
    paginate json: @articles, per_page: params[:limit]
  end

  def show
    render json: @user, serializer: UserShowSerializer
  end

  def balance_account
    render json: @user.balance_account
  end

  def income_account
    render json: @user.income_account
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
