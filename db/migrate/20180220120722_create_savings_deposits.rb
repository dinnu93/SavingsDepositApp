class CreateSavingsDeposits < ActiveRecord::Migration[5.1]
  def change
    create_table :savings_deposits do |t|
      t.string :bank_name
      t.integer :account_number
      t.decimal :initial_amount, precision: 12, scale: 2
      t.datetime :start_date
      t.datetime :end_date
      t.decimal :interest_percentage, precision: 5, scale: 2
      t.decimal :taxes_percentage, precision: 5, scale: 2
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
