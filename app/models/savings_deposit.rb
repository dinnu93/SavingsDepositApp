class SavingsDeposit < ApplicationRecord
  belongs_to :user
  validates_presence_of :bank_name,
                        :account_number,
                        :initial_amount,
                        :start_date,
                        :end_date,
                        :interest_percentage,
                        :taxes_percentage,
                        :user_id


  def as_json(options={})
    {
      id: self.id,
      bank_name: self.bank_name,
      account_number: self.account_number,
      initial_amount: self.initial_amount,
      start_date: self.start_date,
      end_date: self.end_date,
      interest_percentage: self.interest_percentage.to_f,
      taxes_percentage: self.taxes_percentage.to_f,
      user_id: self.user_id
    }
  end
end
