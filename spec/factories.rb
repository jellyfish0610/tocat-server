require 'factory_girl_rails'

FactoryGirl.define do
  factory :order do
    sequence(:name) { |n| "Order #{n}" }
    team_id 1
    invoiced_budget 10
    free_budget 1
    allocatable_budget 9
    invoice_id 1
    association :team
  end

  factory :role do
    sequence(:name) { |n| "Role #{n}" }
  end

  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    default_commission 30
    parent_id 1

    to_create {|instance| instance.save(validate: false) }
  end

  factory :task_orders do
    association :task
    association :order
    sequence(:budget) { |n| BigDecimal.new n }
  end

  factory :task do
    sequence(:external_id) { |n| n }
    association :user
  end

  factory :account do
    account_type ''
    accountable_id 1
    accountable_type 'Team'
  end

  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:login) { |n| "usr#{n}" }
    sequence(:email) { |n| "usr#{n}@example.com" }
    association :team
    daily_rate 50
    association :role
  end

  factory :transaction do
    total 999
    sequence(:comment) { |n| "Transaction #{n}" }
    account_id 1
    user_id 1
  end
end
