require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:dinesh)
  end
  test "valid user" do
    assert @user.valid?
  end
  test "invalid without name" do
    @user.name = nil
    refute @user.valid?, "saved user without name"
    assert_not_nil @user.errors[:name], 'no validation errors for name present'
  end
  test "invalid without email" do
    @user.email = nil
    refute @user.valid?, "saved user without email"
    assert_not_nil @user.errors[:email], 'no validation errors for email present'
  end
  test "invalid without a unique email" do
    assert_not @user.dup.valid?, 'saved user without unique email address'
  end
end
