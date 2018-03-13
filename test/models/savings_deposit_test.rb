require 'test_helper'

class SavingsDepositTest < ActiveSupport::TestCase
  def setup
    @deposit_one = savings_deposits(:deposit_one)
    @deposit_two = savings_deposits(:deposit_two)
  end
  test "valid user" do
    assert @deposit_one.valid?
  end
  test "invalid without bank name" do
    @deposit_one.bank_name = nil
    refute @deposit_one.valid?, "saved deposit without bank name"
  end
  test "invalid without associated user" do
    @deposit_one.user_id = nil
    refute @deposit_one.valid?, "saved deposit without an associated user"
  end
end
