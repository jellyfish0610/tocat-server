class Order < ActiveRecord::Base
  validates :name, presence: { message: "Order name can not be empty" }
  validates :team_id, presence: true
  validates_numericality_of :invoiced_budget,
                            greater_than: 0,
                            message: "Invoiced budget should be greater than 0"
  # validates_numericality_of :free_budget,
  #                           greater_than: 0,
  #                           message: "Unexpected error: 'Free budget should be greater than 0'. Please contact administrator"
  validates_numericality_of :allocatable_budget,
                            greater_than_or_equal_to: 0,
                            message: "Allocatable should be positive number"
  validates_presence_of :invoiced_budget
  validates_presence_of :allocatable_budget
  scoped_search on: [:name, :description, :invoiced_budget, :allocatable_budget, :free_budget, :paid, :completed]
  scoped_search in: :team, on: :name, rename: :team, only_explicit: true
  scoped_search on: :parent_id, only_explicit: true




  validate :check_budgets
  validate :check_if_team_exists
  validate :sub_order_team
  validate :check_inheritance
  validate :check_budgets_for_sub_order
  validate :check_sub_order_after_update

  belongs_to :team
  belongs_to :invoice
  has_many :task_orders, class_name: 'TaskOrders'
  has_many :tasks, through: :task_orders

  has_many :sub_orders, class_name: 'Order', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Order'

  before_save :set_free_budget, if: proc { |o| o.new_record? }
  before_destroy :check_if_order_has_tasks
  before_destroy :check_for_suborder
  before_save :check_if_paid, if: proc { |o| o.invoice_id_changed? }
  before_destroy :check_if_paid_before_destroy
  after_destroy :recalculate_parent_free_budget, if: proc { |o| o.parent_id.present? }
  before_save :check_if_paid_on_budget_update, if: proc { |o| o.invoiced_budget_changed? }
  before_save :check_if_invoice_already_paid, if: proc { |o| o.invoice_id_changed? }
  before_save :check_for_tasks_on_team_change, if: proc { |o| o.team_id_changed? }
  before_save :check_if_suborder, if: proc { |o| o.invoice_id_changed? }
  before_save :paid_from_parent, if: proc { |o| o.parent_id.present? }
  before_save :check_if_allocatable_budget_lt_used, if: proc { |o| o.allocatable_budget_changed? }
  before_save :recalculate_free_budget, if: proc { |o| o.allocatable_budget_changed? && !o.new_record? }
  after_save :recalculate_parent_free_budget, if: proc { |o| o.allocatable_budget_changed? && !o.new_record? && o.parent.present? }
  before_save :check_for_completed, if: proc { |o| !o.completed_changed? }
  before_save :check_for_paid_before_change_completed, if: proc { |o| o.completed_changed? }
  before_save :check_if_suborder_before_change_completed, if: proc { |o| o.completed_changed? }
  before_save :check_for_accepted_tasks_before_completed, if: proc { |o| o.completed_changed? }
  before_save :check_if_parent_completed_on_suborder_creation, if: proc { |o| o.new_record? && o.parent_id.present? }
  before_save :handle_completed, if: proc { |o| o.completed_changed? && o.parent_id.nil? }
  before_destroy :check_if_parent_completed, if: proc { |o| o.parent_id.present? }

  def handle_paid(paid)
    self.update_attributes!(paid: paid)
  end

  def recalculate_free_budget!
    recalculate_free_budget_and_save
  end

  def handle_completed
    self.transaction do
      if completed
        sub_orders.each do |suborder|
          # вычитаем бюджеты тасков
          val = suborder.invoiced_budget - suborder.task_orders.sum(:budget)
          suborder.team.income_account.transactions.create! total: val,
                                                            comment: "Order ##{suborder.id} was completed",
                                                            user_id: 0
          suborder.update_columns(completed: true)
        end
        #из ивойсед вычитаем сабордеры и таски
        val = invoiced_budget - sub_orders.sum(:invoiced_budget) - task_orders.sum(:budget)
        team.income_account.transactions.create! total: val,
                                                 comment: "Order ##{id} was completed",
                                                 user_id: 0
      else
        sub_orders.each do |suborder|
          val = suborder.invoiced_budget - suborder.task_orders.sum(:budget)
          suborder.team.income_account.transactions.create! total: -val,
                                                            comment: "Order ##{suborder.id} was uncompleted",
                                                            user_id: 0
          suborder.update_columns(completed: false)
        end
        val = invoiced_budget - sub_orders.sum(:invoiced_budget) - task_orders.sum(:budget)
        team.income_account.transactions.create! total: -val,
                                                 comment: "Order ##{id} was uncompleted",
                                                 user_id: 0
      end
    end
  end


  private

  def check_if_parent_completed
    if parent.try(:completed)
      errors[:base] << 'Can not delete suborder when parent order completed'
      false
    end
  end

  def check_if_parent_completed_on_suborder_creation
    if parent.completed?
      errors[:base] << 'Can not create suborder from completed order'
      false
    end
  end

  def check_for_accepted_tasks_before_completed
    tasks_array = []
    tasks_array << tasks
    tasks_array << sub_orders.collect(&:tasks)
    tasks_array.flatten!
    ids = tasks_array.select { |o| !o.paid || !o.accepted }.collect(&:external_id)
    if ids.any?
      errors[:base] << "Can not complete order: task(s) #{ids.join(',')} not Accepted&Paid"
      false
    end
  end

  def check_if_suborder_before_change_completed
    if parent_id.present?
      if completed
        errors[:base] << 'Can not complete suborder'
      else
        errors[:base] << 'Can not un-complete suborder'
      end
      false
    end
  end

  def check_for_paid_before_change_completed
    unless paid
      errors[:base] << 'Can not complete unpaid order'
      false
    end
  end

  def check_for_completed
    if completed_was
      errors[:base] << 'Can not modify completed order'
      false
    else
      true
    end
  end

  def recalculate_parent_free_budget
    parent.recalculate_free_budget!
  end

  def recalculate_free_budget
    val = task_orders.sum(:budget)
    val += sub_orders.sum(:invoiced_budget)
    self.free_budget = allocatable_budget - val
  end

  def recalculate_free_budget_and_save
    val = task_orders.sum(:budget)
    val += sub_orders.sum(:invoiced_budget)
    self.update_attributes!(free_budget: allocatable_budget - val)
  end

  def check_if_allocatable_budget_lt_used
    used_budget = task_orders.sum(:budget)
    used_budget += sub_orders.sum(:allocatable_budget)
    if allocatable_budget < used_budget
      errors[:base] << 'Allocatable bugdet is less than already used from order'
      false
    end
  end

  def paid_from_parent
    self.paid = parent.paid
    true
  end

  def check_if_suborder
    if parent.present?
      errors[:base] << 'Suborder can not be invoiced'
      false
    end
  end

  def check_for_tasks_on_team_change
    if tasks.present?
      errors[:base] << 'Can not change order team - order is used in tasks'
      false
    end
  end

  def check_if_invoice_already_paid
    if invoice.present?
      if invoice.paid
        errors[:base] << 'Invoice is already paid, can not use it for new order'
        false
      end
    end
  end

  def check_if_paid_on_budget_update
    if paid && parent_id.nil?
      errors[:base] << 'Order is already paid, can not update invoiced budget'
      return false
    end
  end

  def check_if_paid_before_destroy
    if paid
      errors[:base] << 'Can not delete already paid invoice'
      return false
    end
  end

  def check_if_paid
    if paid
      if invoice_id.nil?
        errors[:base] << 'Order is already paid, can not unlink it from invoice'
      else
        errors[:base] << 'Order is already paid, can not change invoice'
      end
      false
    end
  end

  def check_for_suborder
    if sub_orders.present?
      errors[:base] << 'You can not delete order when there is a suborder'
      false
    end
  end

  def check_if_order_has_tasks
    if tasks.present?
      errors[:base] << 'You can not delete order that is used in task budgeting'
      false
    end
  end

  def check_sub_order_after_update
    if parent.present?
      if allocatable_budget_changed? || invoiced_budget_changed?
        if allocatable_budget > (parent.free_budget + allocatable_budget_was.to_i) || invoiced_budget > (parent.free_budget + invoiced_budget_was.to_i)
          errors[:base] << 'Suborder can not be invoiced more than parent free budget'
        end
      end
    end
  end

  def sub_order_team
    if new_record? && parent.present?
      if team == parent.team
        errors[:base] << 'Suborder can not be created for the same team as parent order'
      end
    end
  end

  def check_budgets_for_sub_order
    if new_record? && parent.present?
      if invoiced_budget > parent.free_budget
        errors[:base] << 'Suborder can not be invoiced more than parent free budget'
      end
    end
  end

  def check_inheritance
    if new_record? && parent.present?
      if self.parent.parent.present?
        errors[:base] << 'Suborder can not be created from another suborder'
      end
    end
  end

  def check_budgets
    if allocatable_budget.present? && invoiced_budget.present?
      if allocatable_budget > invoiced_budget
        errors[:base] << "Allocatable budget is greater than invoiced budget"
      end
    end
  end

  def check_if_team_exists
    if team_id.present?
      errors[:base] << 'Team does not exists' unless Team.exists?(id: team_id)
    end
  end

  def set_free_budget
    if new_record?
      if parent
        val = parent.free_budget - invoiced_budget
        parent.update_attributes(free_budget: val)
      end
      self.free_budget = allocatable_budget
    elsif invoiced_budget_changed?
      if parent
        val = parent.free_budget - invoiced_budget
        parent.update_attributes(free_budget: val)
      end
    elsif allocatable_budget_changed?
      self.free_budget = allocatable_budget
    end
  end
end
