class AddColumnActivationStatusToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :activation_status, :integer, default: 0
  end
end
