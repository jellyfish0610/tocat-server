class User < ActiveRecord::Base
  include Accounts
  include PublicActivity::Common
  validates :name, presence: true
  validates :login, presence: true
  validates :daily_rate,
            numericality: { greather_than: 0 },
            presence: true

  belongs_to :team
  belongs_to :role
  validates :team_id, presence: true
  validates :role_id, presence: true
  validate :team_can_have_only_one_manager

  has_many :transactions
  has_many :tasks

  before_save :normalize_data
  scope :all_active, ->{where(active: true)}

  scoped_search on: [:name, :login]
  scoped_search in: :team, on: :name, rename: :team, only_explicit: true
  scoped_search in: :role, on: :name, rename: :role, only_explicit: true

  delegate :manager?, to: :role

  def self.current_user
    Thread.current[:current_user]
  end

  def self.current_user=(usr)
    Thread.current[:current_user] = usr
  end

  def add_payment(comment, total)
    self.transaction do
      income_account.transactions.create! total: -total.to_i,
                                          comment: comment,
                                          user_id: id
      create_activity key: 'user.add_payment',
                      parameters: { total: -total.to_i, comment: comment },
                      recipient: self,
                      owner: User.current_user
    end
  end

  private

  def normalize_data
    self.login = self.login.downcase
    self.name = self.name.titleize
  end
  def team_can_have_only_one_manager
    errors.add 'Team', 'already have a manager' if self.role.try(:name) == 'Manager' && self.team.roles.managers.any? #TODO - fix 
  end
end
