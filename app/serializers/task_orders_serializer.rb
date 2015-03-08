class TaskOrdersSerializer < ActiveModel::Serializer
  attributes :order_id, :budget

  private

  def budget
    object.budget.to_f
  end
end
