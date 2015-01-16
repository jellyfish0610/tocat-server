class UserShowSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id,
             :name,
             :login,
             :team,
             :daily_rate,
             :role,
             :links

  private

  def team
    data = {}
    data[:name] = object.team.name
    data[:href] = team_path(object.team)
    data
  end

  def role
    object.role.name
  end

  def links
    data = {}
    data[:href] = user_path(object)
    data[:rel] = 'self'
    data
  end

  def attributes
    data = super
    balance = {}
    income = {}
    balance[:id] = object.balance_account.id
    balance[:href] = user_balance_path(object)
    income[:id] = object.income_account.id
    income[:href] = user_income_path(object)
    data[:balance_account] = balance
    data[:income_account] = income
    data
  end
end
