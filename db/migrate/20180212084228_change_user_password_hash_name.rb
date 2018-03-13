class ChangeUserPasswordHashName < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.rename :password_hash, :password_digest
    end
  end
end
