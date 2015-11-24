class Team < ActiveRecord::Base
  include Accounts
  include PublicActivity::Common
  validates :name, presence: true
  has_many :orders
  has_many :users
  has_many :roles, :through => :users, source: :role
end
