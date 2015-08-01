class TaskOrders < ActiveRecord::Base
  validates :task_id, presence: true
  validates :order_id, presence: true
  validates :budget,
           numericality: { greater_than: 0 },
           presence: true
  validate :check_resolver_team_after_budget_creation, if: proc { |o| o.new_record? }
  validate :resolver_presence

  validates_uniqueness_of :task_id, scope: [:order_id]
  validates_uniqueness_of :order_id, scope: [:task_id]

  belongs_to :order
  belongs_to :task

  before_save :check_free_budget
  before_save :check_if_order_completed
  before_save :check_if_task_accepted_and_paid
  before_destroy :check_if_task_accepted_and_paid
  before_save :decrease_free_budget
  before_destroy :increase_free_budget

  private

  def check_if_task_accepted_and_paid
    if task.accepted && task.paid
      errors[:budget] << 'Can not update budget for task that is Accepted and paid'
      return false
    end
  end

  def check_if_order_completed
    if order.completed
      errors[:budget] << "Completed order is used in budgets, can not update task"
      false
    else
      true
    end
  end

  def resolver_presence
    return true if try(:task).try(:team).nil?
    unless task.team == order.team
      errors[:orders] << "Orders are created for different teams"
    end
  end

  def check_resolver_team_after_budget_creation
    return true unless try(:task).try(:user).present?
    if task.user.team != order.team
      errors[:resolver] << "Task resolver is from different team than order"
    end
  end

  def check_free_budget
    if self.budget > self.order.free_budget
      errors[:budget] << 'You can not assign more budget than is available on order'
      false
    end
  end

  def decrease_free_budget
    if new_record?
      self.order.update_attributes(free_budget: order.free_budget - budget)
    else
      order.free_budget += budget_was
      new_free_budget = order.free_budget - budget
      order.update_attributes(free_budget: new_free_budget)
    end
  end

  def increase_free_budget
    val = self.order.free_budget + self.budget
    self.order.update_attribute(:free_budget, val)
  end
end
