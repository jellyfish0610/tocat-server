class Order < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :team_id
  validates :invoiced_budget,
              :numericality => { :greater_than => 0 },
              :presence => true
  validates :allocatable_budget,
              :numericality => { :greater_than => 0 },
              :presence => true

  validate :check_budgets
  validate :check_if_team_exists

  belongs_to :team
  has_many :invoices
  has_many :task_orders, :class_name => 'TaskOrders'
  has_many :tasks, through: :task_orders


  private

  def check_budgets
    if allocatable_budget.present? and invoiced_budget.present?
      if allocatable_budget > invoiced_budget
        errors.add(:allocatable_budget, "must be lower than Invoiced Budget")
      end
    end
  end

  def check_if_team_exists
    if team_id.present?
      errors.add(:team_id, "should exists") unless Team.exists?(:id => team_id)
    end
  end
end
