require 'rails_helper'
require 'factory_girl_rails'


RSpec.describe Order, :type => :model do

  context "validations" do
    before(:all) {create(:team)}

    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:team_id)}
    it {should validate_presence_of(:invoiced_budget)}
    it {should validate_presence_of(:allocatable_budget)}
    it {should belong_to(:team)}
    it {should have_many(:invoices)}

    it "should fail if allocatable budget more than invoiced" do
      order = build(:order)
      order.allocatable_budget = 999
      order.valid?
      order.errors.should have_key(:allocatable_budget)
    end

    it "should fail if allocatable budget equals zero " do
      order = build(:order)
      order.allocatable_budget = 0
      order.valid?
      order.errors.should have_key(:allocatable_budget)
    end

    it "should fail if invoiced budget equals zero " do
      order = build(:order)
      order.invoiced_budget = 0
      order.allocatable_budget = 0
      order.valid?
      order.errors.should have_key(:invoiced_budget)
    end

    it "should fail if team does not exists" do
      order = build(:order)
      order.team_id = 9999
      order.valid?
      order.errors.should have_key(:team_id)
    end
  end
end
