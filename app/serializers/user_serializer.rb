class UserSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :login, :team, :role, :links

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
end
