class BalanceTransfer < ActiveRecord::Base # internal payment
  include PublicActivity::Common
  belongs_to :source, class_name: Account
  belongs_to :target, class_name: Account
  belongs_to :target_transaction, class_name: Transaction
  belongs_to :source_transaction, class_name: Transaction
  validates :description, :total ,:presence => true
 
  validates :source_id, presence: true
  validates :target_id, presence: true

  validates :description, length: { maximum: 250 }
  attr_accessor :target_login

  validates_numericality_of :total, 
                            greater_than: 0,
                            message: "Total of internal payment should be greater than 0"
  before_validation :set_date
  after_validation :create_transactions
  #scoped_search in: :source, on: :accountable_id, rename: :source
  #scoped_search in: :target, on: :accountable_id, rename: :target
  
  def as_json(options={})
    additional_params = {source: source.try(:accountable).try(:name)||source.try(:name), target: target.try(:accountable).try(:name)||target.try(:name)}
    self.attributes.merge additional_params
  end

  private
  
  def set_date
    self.created = Time.now
  end
  
  def create_transactions
    comment = "Balance transfer:  #{self.description}".truncate 255 # TODO - transaction comment should be not more 255 symbols
    self.source_transaction = source.transactions.create! total: -total, comment: comment
    self.target_transaction = target.transactions.create! total: total, comment: comment
  end
end
