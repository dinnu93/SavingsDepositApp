require 'test_helper'

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
   setup do
    @user = {name: "User",
              email: "user@user.com",
              password: "password"}
    post users_url, params: @user
  end

  teardown do
    Rails.cache.clear
  end
  test "Can't create the auth token without email" do
    @user[:name] = nil
    @user[:email] = nil
    post authenticate_url, params: @user
    assert_response :unauthorized
  end
  test "Can't create the auth token without password" do
    @user[:name] = nil
    @user[:password] = nil
    post authenticate_url, params: @user
    assert_response :unauthorized
  end
  test "Can't create the auth token with inactive user account" do
    @user[:name] = nil
    post authenticate_url, params: @user
    assert_response :unauthorized
  end
  test "Can't create the auth token with invalid credentials" do
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    @user[:name] = nil
    @user[:password] = "not password"
    post authenticate_url, params: @user
    assert_response :unauthorized
  end
  test "Create the auth token with email and password" do
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    @user[:name] = nil
    post authenticate_url, params: @user
    assert_response :success
  end
  test "Create the auth token with auth_token" do
    mail = ActionMailer::Base.deliveries.last
    activation_link = /http:(.+)/.match(mail.to_s) 
    activation_link = activation_link.to_s.gsub('%40','@')
    get activation_link
    @user[:name] = nil
    post authenticate_url, params: @user
    assert_response :success
    auth_token = JSON.parse(@response.body)["auth_token"]
    post authenticate_url, headers: {"Authorization": "Basic #{auth_token}"}
    assert_response :success
  end
end
