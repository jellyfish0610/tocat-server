class Team < ActiveRecord::Base
  validates_presence_of :name
  has_many :orders
  has_many :accounts, as: :accountable
  has_many :users

  after_create :create_accounts
  after_destroy :destroy_accounts

  def balance_account
    Account.where(:accountable_id => self.id,
                  :accountable_type => self.class.name,
                  :account_type => 'balance').first
  end

  def income_account
    Account.where(:accountable_id => self.id,
                  :accountable_type => self.class.name,
                  :account_type => 'payment').first
  end

  private

    def create_accounts
      balance = self.accounts.create! :account_type => 'balance'
      payment = self.accounts.create! :account_type => 'payment'
      self.balance_account_id = balance.id
      self.gross_profit_account = payment.id
      self.save!
    end

    def destroy_accounts
      self.accounts.destroy_all
    end
end
