class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show, :create] 
  def index
    @users = User.all
    render json: @users
  end

  def show
    if User.exists?(params[:id])
      @user = User.find(params[:id])
      render json: @user
    else
      render json: {error_msgs: "User with id: #{params[:id]} doesn't exist!"}, status: :not_found
    end
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.send_activation_link(@user).deliver_now
      render json: {success: "Account successfully created, check you email for activation link!"}
    else
      render json: {error_msgs: @user.errors.full_messages}, status: :bad_request
    end
  end

  def update
    if User.exists?(params[:id])
      @user = User.find(params[:id])
      if !user_update_params[:role].nil? && @current_user.role != "admin"
        render json: {error_msg: "Only admin user can promote roles!"}, status: :unauthorized
      elsif user_update_params[:role] && @current_user.role == "admin" && user_update_params[:role] == "admin"
        render json: {error_msg: "No one can make admin users!"}, status: :unauthorized
      elsif (@user.id == @current_user.id || User.roles[@current_user.role] > User.roles[@user.role]) &&  @user.update(user_update_params)
        render json: {success_msg: "User successfully updated"}
      elsif @user.id != @current_user.id
        render json: {error_msg: "Unauthorized user!"}, status: :unauthorized
      else
        render json: {error_msgs: @user.errors.full_messages}, status: :bad_request
      end
    else
      render json: {error_msgs: "User with id: #{params[:id]} doesn't exist!"}, status: :not_found
    end
  end

  def destroy
    if User.exists?(params[:id])
      @user = User.find(params[:id])
      if (@user.id == @current_user.id || User.roles[@current_user.role] > User.roles[@user.role]) && @user.destroy
        render json: {status_msg: "User named #{@user.name} is deleted." }
      elsif @user.id != @current_user.id
        render json: {error_msg: "Unauthorized user!"}, status: :unauthorized
      else
        render json: {error_msgs: @user.errors.full_messages}, status: :bad_request
      end
    else
      render json: {error_msgs: "User with id: #{params[:id]} doesn't exist!"}, status: :not_found
    end
  end

  def generate_revenue_report
    if User.exists?(params[:id])
      @user = User.find(params[:id])
      @savings_deposits = @user.savings_deposits
      if params[:start_date] && params[:end_date] && (@user.id == @current_user.id || @current_user.role == "admin")
        start_date = params[:start_date].to_date
        end_date = params[:end_date].to_date
        render json: make_revenue_report(@savings_deposits, start_date, end_date)
      elsif params[:start_date].nil? || params[:end_date].nil?
        render json: {error_msg: "Start date and end date not present!"}, status: :bad_request
      else
        render json: {error_msg: "Unauthorized user!"}, status: :unauthorized
      end
    else
      render json: {error_msgs: "User with id: #{params[:id]} doesn't exist!"}, status: :not_found
    end
  end
  private
  def user_params
    params.permit(:name,:email,:password)
  end
  def user_update_params
    params.permit(:id,:name,:email,:password,:role)
  end
  def make_revenue_report(savings_deposits, start_date, end_date)
    savings_deposits.map { |savings_deposit|
      if start_date <= savings_deposit.end_date.to_date &&
         end_date >= savings_deposit.start_date.to_date &&
         start_date <= end_date
        if start_date < savings_deposit.start_date.to_date
          start_date = savings_deposit.start_date.to_date
        elsif end_date > savings_deposit.end_date.to_date
          end_date = savings_deposit.end_date.to_date
        end
        duration = (end_date - start_date).to_i # Number of days between the start & end date
      else
        duration = 0
      end
      profit = profit_from_interest(savings_deposit, duration)
      loss = loss_from_taxes(savings_deposit, profit)
      net = profit - loss
      savings_deposit_hash = savings_deposit.as_json
      savings_deposit_hash["net"] = net.to_f.round(2)
      savings_deposit_hash["profit"] = profit.to_f.round(2)
      savings_deposit_hash["loss"] = loss.to_f.round(2)
      savings_deposit_hash
    }
  end
  
  def profit_from_interest(savings_deposit, duration)
    days_in_a_year = 360.0
    interest_per_year = savings_deposit.interest_percentage
    initial_amount = savings_deposit.initial_amount
    profit = (initial_amount * (duration / days_in_a_year) * interest_per_year) / 100.0
    profit
  end
  def loss_from_taxes(savings_deposit, profit)
    loss = (profit * savings_deposit.taxes_percentage) / 100.0
    loss
  end
end

