class AccountActivationsController < ApplicationController
  skip_before_action :authenticate_request
  
  def edit
    user_activation_token = user_params[:id]
    user_email = user_params[:email]
    if User.exists?(email: user_email)
      user = User.find_by_email(user_email)
      user_activation_digest =  BCrypt::Password.new(user.activation_digest)
      if user_activation_digest == user_activation_token
        if !user.activated && user.activated_at.nil?
          user.update_attributes(activated: true, activated_at: Time.now)
          render json: {success: "Account successfully activated!"}
        elsif user.activated && !user.activated_at.nil?
          render json: {error_msg: "Account already activated before!"}, status: :bad_request
        end
      else
        render json: {error_msg: "Bad activation token!"}, status: :bad_request
      end
    else
      render json: {error_msg: "User with email address: #{user_email} doesn't exist!"}, status: :not_found
    end
  end

  private
  def user_params
    params.permit(:id,:email)
  end
end
