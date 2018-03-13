require 'test_helper'

class SavingsDepositsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  def activate_account(user)
    user.update_attributes(activated: true, activated_at: Time.now)
  end
  setup do
    @dinesh = users(:dinesh)
    activate_account(@dinesh)
    @vaishnavi = users(:vaishnavi)
    activate_account(@vaishnavi)
    @deposit_one = savings_deposits(:deposit_one)
    @deposit_two = savings_deposits(:deposit_two)
  end
  
  teardown do
    Rails.cache.clear
  end

  # Tests for the index method
  test "Don't show the savings deposits of a user if not authorized" do
    get user_savings_deposits_url(@dinesh.id)
    assert_response :unauthorized
  end
  test "Don't show the savings deposits of another user even though the current user is authorized" do
    post authenticate_url, params: {email: @vaishnavi.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    get user_savings_deposits_url(@dinesh.id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :unauthorized
  end
  test "Show the savings deposits of a user to only that user if authorized" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    get user_savings_deposits_url(@dinesh.id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end

  test "Show the savings deposits of a user to only that user if authorized and filter according to the bank_name" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    get user_savings_deposits_url(@dinesh.id,
                                  bank_name: @deposit_one.bank_name,
                                  min_amount: @deposit_one.initial_amount-100,
                                  max_amount: @deposit_one.initial_amount+100,
                                  date: @deposit_one.start_date), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
  #Tests for the create method
  test "Create the savings deposit if the user creates one himself" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    post user_savings_deposits_url(@dinesh.id), params:{bank_name: "State Bank of India",
                                                        account_number: 62445376806,
                                                        initial_amount: 4000,
                                                        start_date: Time.now,
                                                        end_date: 10.years.from_now,
                                                        interest_percentage: 12,
                                                        taxes_percentage: 10}, headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end

  test "Don't create the savings deposit if the user tries to create one for another user" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    post user_savings_deposits_url(@vaishnavi.id), params:{bank_name: "State Bank of India",
                                                        account_number: 62445376806,
                                                        initial_amount: 4000,
                                                        start_date: Time.now,
                                                        end_date: 10.years.from_now,
                                                        interest_percentage: 12,
                                                        taxes_percentage: 10}, headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :unauthorized
  end

  test "Create the savings deposit if the admin creates one for another user" do
    @dinesh.update_attribute(:role, :admin)
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    post user_savings_deposits_url(@vaishnavi.id), params:{bank_name: "State Bank of India",
                                                        account_number: 62445376806,
                                                        initial_amount: 4000,
                                                        start_date: Time.now,
                                                        end_date: 10.years.from_now,
                                                        interest_percentage: 12,
                                                        taxes_percentage: 10}, headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end

  #Tests for the show method

  test "Show the savings deposit if the user who created it wants to see" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    get user_savings_deposit_url(@dinesh.id, @deposit_one.id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end

  test "Don't show the non-existent savings deposit if the user wants to see" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    deposit_id = @deposit_one.id + 1
    get user_savings_deposit_url(@dinesh.id, deposit_id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :not_found
  end

  test "Don't show the savings deposit if the user tries to see one of another user" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    get user_savings_deposit_url(@vaishnavi.id, @deposit_two.id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :unauthorized
  end

  test "Show the savings deposit if the admin wants to see  another user's" do
    @dinesh.update_attribute(:role, :admin)
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    get user_savings_deposit_url(@vaishnavi.id, @deposit_two.id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end

  #Tests for the update method
  test "Update the savings deposit if the user created one himself" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    put user_savings_deposit_url(@dinesh.id,@deposit_one.id), params:{initial_amount: 2000,
                                                                       end_date: 5.years.from_now
                                                                     }, headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end

  test "Don't update the savings deposit if the user created one himself and wants to change the user_id" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    put user_savings_deposit_url(@dinesh.id,@deposit_one.id), params:{initial_amount: 2000,
                                                                      new_user_id: @vaishnavi.id
                                                                     }, headers: {"Authorization": "Basic #{auth_token}"}
    get user_savings_deposit_url(@vaishnavi.id,@deposit_one.id)
    assert_response :unauthorized
  end

  test "Don't update the savings deposit if the user tries to update one for another user" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    put user_savings_deposit_url(@vaishnavi.id,@deposit_two.id), params:{initial_amount: 2000,
                                                                         end_date: 5.years.from_now
                                                                        }, headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :unauthorized
  end

  test "Update the savings deposit if the admin updates one for another user and also changes the user_id" do
    @dinesh.update_attribute(:role, :admin)
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    put user_savings_deposit_url(@vaishnavi.id,@deposit_two.id), params:{initial_amount: 4000,
                                                         new_user_id: @dinesh.id
                                                        }, headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end

  # Tests for the destroy method

  test "Destroy if the user wants to destroy the savings deposit" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    delete user_savings_deposit_url(@dinesh.id, @deposit_one.id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
  test "Don't destroy if the user wants to destroy the savings deposit he didn't create" do
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    get user_savings_deposit_url(@vaishnavi.id, @deposit_two.id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :unauthorized
  end
  test "Destroy any savings deposit if the admin wants to destroy it" do
    @dinesh.update_attribute(:role, :admin)
    post authenticate_url, params: {email: @dinesh.email, password: "password"}
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    get user_savings_deposit_url(@vaishnavi.id, @deposit_two.id), headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
end
