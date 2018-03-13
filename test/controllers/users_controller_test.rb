require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  setup do
    @user = users(:dinesh)
    @user.update_attributes(activated: true, activated_at: Time.now)
    @another_user = {name: "Another User",
              email: "another.user@notme.com",
              password: "password"}
  end

  teardown do
    Rails.cache.clear
  end

  # Tests for the index method
  test "show all the users" do
    get users_url
    assert_response :success
  end

  # Tests for the show method
  test "show the user" do
    get user_url(@user)
    assert_response :success
  end
  test "don't show the user" do
    get user_url(@user.id+1)
    assert_response :not_found
  end

  # Tests for the create method
  test "create the user" do
    assert_emails 1 do
      post users_url, params: @another_user
      assert_response :success
    end
  end
  test "don't create the user with duplicate email" do
    post users_url, params: @another_user
    post users_url, params: @another_user.dup
    assert_response :bad_request
  end
  test "don't create the user without email" do
    @another_user[:email] = nil
    post users_url, params: @another_user
    assert_response :bad_request
  end
  test "don't create the user without name" do
    @another_user[:name] = nil
    post users_url, params: @another_user
    assert_response :bad_request
  end
  test "don't create the user without password" do
    @another_user[:password] = nil
    post users_url, params: @another_user
    assert_response :bad_request
  end

  # Tests for the update method
  test "update the user when he wants to change his account" do
    post users_url, params: @another_user
    user_id = User.find_by_email(@another_user[:email]).id
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    assert_response :success
    post authenticate_url, params: @another_user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    put "/users/#{user_id}", params: {name: "Same User"} ,headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
  test "don't update the user when some other user wants to change the user account" do
    post users_url, params: @another_user
    user_id = User.find_by_email(@another_user[:email]).id
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    assert_response :success
    post authenticate_url, params: @another_user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    put "/users/#{@user.id}", params: {name: "Same User"} ,headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :unauthorized
  end
  test "update when the user_manager wants to change the user account" do
    post users_url, params: @another_user
    another_user = User.find_by_email(@another_user[:email])
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    assert_response :success
    post authenticate_url, params: @another_user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    another_user.update_attribute(:role,:user_manager)
    put "/users/#{@user.id}", params: {name: "Same User"} ,headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
  test "update when the admin wants to change the user account" do
    post users_url, params: @another_user
    another_user = User.find_by_email(@another_user[:email])
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    assert_response :success
    post authenticate_url, params: @another_user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    another_user.update_attribute(:role,:admin)
    put "/users/#{@user.id}", params: {name: "Same User"} ,headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
  
  # Tests for the destroy method
  test "delete the user if he wants to delete his account" do
    post users_url, params: @another_user
    user_id = User.find_by_email(@another_user[:email]).id
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    assert_response :success
    post authenticate_url, params: @another_user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    delete "/users/#{user_id}", headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
   test "don't delete the user when some other user wants to delete the user account" do
    post users_url, params: @another_user
    user_id = User.find_by_email(@another_user[:email]).id
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    assert_response :success
    post authenticate_url, params: @another_user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    delete "/users/#{@user.id}", headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :unauthorized
   end
   test "delete when the user_manager wants to delete the user account" do
    post users_url, params: @another_user
    another_user = User.find_by_email(@another_user[:email])
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    assert_response :success
    post authenticate_url, params: @another_user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    another_user.update_attribute(:role,:user_manager)
    delete "/users/#{@user.id}", headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
  test "delete when the admin wants to delete the user account" do
    post users_url, params: @another_user
    another_user = User.find_by_email(@another_user[:email])
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    assert_response :success
    post authenticate_url, params: @another_user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    another_user.update_attribute(:role,:admin)
    delete "/users/#{@user.id}", headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end

  # Test for generate revenue report method
  test "Generate the revenue report" do
    post authenticate_url, params: {email: @user.email, password: "password"}
    auth_token = JSON.parse(@response.body)["auth_token"]
    assert_response :success
    get "/users/#{@user.id}/generate_revenue_report?start_date=2018-02-22&end_date=2028-02-22", headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
end
