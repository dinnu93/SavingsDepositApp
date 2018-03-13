class AddActivationDigestToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :activation_digest, :string
    add_column :users, :activated_at, :datetime
    remove_column :users, :activation_status
    add_column :users, :activated, :boolean, default: false
  end
end
