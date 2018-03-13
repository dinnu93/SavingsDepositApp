class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    if request.headers['Authorization'].present?
      command = AuthorizeApiRequest.call(request.headers)
      if command.success?
        user = command.result
        render json: { auth_token: JsonWebToken.encode(user_id: user.id)}
      else
        render json: {error_msg: "Invalid auth token"}, status: :unauthorized
      end
    else
      command = AuthenticateUser.call(params[:email], params[:password])
      if command.success?
        render json: { auth_token: command.result }
      else
        render json: { error_msg: command.errors[:user_authentication].first }, status: :unauthorized
      end
    end
  end
end
