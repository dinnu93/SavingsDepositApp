class ChangeAccountNumberColumnInSavingsDeposits < ActiveRecord::Migration[5.1]
  def change
    change_column :savings_deposits, :account_number, :bigint
  end
end
