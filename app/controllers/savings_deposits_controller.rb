class SavingsDepositsController < ApplicationController
  def index
    if User.exists?(params[:user_id])
      @user = User.find(params[:user_id])
      if @current_user.id == @user.id || @current_user.role == "admin"
        if (params[:min_amount] && params[:max_amount]) && params[:bank_name] && params[:date]
          render json: @user.savings_deposits.
                   where("initial_amount >= ? && initial_amount <= ?",params[:min_amount],params[:max_amount]).
                   where(bank_name: params[:bank_name], start_date: params[:date])
        elsif (params[:min_amount] && params[:max_amount]) && params[:bank_name]
          render json: @user.savings_deposits.
                   where("initial_amount >= ? && initial_amount <= ?",params[:min_amount],params[:max_amount]).
                   where(bank_name: params[:bank_name])
        elsif params[:bank_name] && params[:date]
          render json: @user.savings_deposits.
                   where(bank_name: params[:bank_name], start_date: params[:date])
        elsif (params[:min_amount] && params[:max_amount]) && params[:date]
          render json: @user.savings_deposits.
                   where("initial_amount >= ? && initial_amount <= ?",params[:min_amount],params[:max_amount]).
                   where(start_date: params[:date])
        elsif (params[:min_amount] && params[:max_amount])
          render json: @user.savings_deposits.
                   where("initial_amount >= ? && initial_amount <= ?",params[:min_amount],params[:max_amount])
        elsif  params[:bank_name]
          render json: @user.savings_deposits.
                   where(bank_name: params[:bank_name])
        elsif params[:date]
          render json: @user.savings_deposits.
                   where(start_date: params[:date])
        else
          render json: @user.savings_deposits
        end
      else
        render json: {error_msg: "You're not authorized to see other user's deposits"}, status: :unauthorized
      end
    else
      render json: {error_msgs: "User with id: #{params[:user_id]} doesn't exist!"}, status: :not_found
    end
  end
  
  def create
    if User.exists?(params[:user_id])
      @user = User.find(params[:user_id])
      if @current_user.id == @user.id || (@current_user.role == "admin" && @user.role != "admin")
        @savings_deposit = SavingsDeposit.new(savings_deposits_params)
        if @savings_deposit.save
          render json: {success_msg: "Savings deposit successfully created!"}
        else
          render json: {error_msg: "Incomplete data!"}, status: :bad_request
        end
      else
        render json: {error_msg: "You're not authorized to create other user's deposits"}, status: :unauthorized
      end
    else
      render json: {error_msgs: "User with id: #{params[:user_id]} doesn't exist!"}, status: :not_found
    end
  end

  def show
    if User.exists?(params[:user_id])
      @user = User.find(params[:user_id])
      if @current_user.id == @user.id || (@current_user.role == "admin" && @user.role != "admin")
        if SavingsDeposit.exists?(id: params[:id], user_id: @user.id)
          @savings_deposit = SavingsDeposit.find(params[:id])
          render json: @savings_deposit
        else
          render json: {error_msgs: "Savings deposit with id: #{params[:id]} and user_id: #{params[:user_id]} doesn't exist!"}, status: :not_found
        end
      else
        render json: {error_msg: "You're not authorized to see other user's deposits"}, status: :unauthorized
      end
    else
      render json: {error_msgs: "User with id: #{params[:user_id]} doesn't exist!"}, status: :not_found
    end
  end
  
  def update
    if User.exists?(params[:user_id])
      @user = User.find(params[:user_id])
      if SavingsDeposit.exists?(id: params[:id], user_id: params[:user_id])
        @savings_deposit = SavingsDeposit.find(params[:id])
        if @current_user.role != "admin" && @current_user.id == @user.id && @savings_deposit.update(savings_deposits_params)
          render json: {success_msg: "Savings deposit successfully updated!"}
        elsif (@current_user.role == "admin" && @current_user.id == @user.id) || (@current_user.role == "admin" && @user.role != "admin")
          admin_params = admin_savings_deposits_params
          if admin_params[:new_user_id]
            admin_params[:user_id] = admin_params[:new_user_id]
            admin_params.delete(:new_user_id)
          end
          if @savings_deposit.update(admin_params)
            render json: {success_msg: "Savings deposit successfully updated!"}
          else
            render json: {error_msg: "Bad request!"}, status: :bad_request
          end
        else
          render json: {error_msg: "Unauthorized request maybe!"}, status: :unauthorized
        end
      else
        render json: {error_msg: "Savings deposit with id: #{params[:id]} and user_id: #{params[:user_id]} doesn't exist"}, status: :not_found
      end
    else
      render json: {error_msg: "User account with id: #{params[:user_id]} doesn't exist"}, status: :not_found
    end   
  end

  def destroy
    if User.exists?(params[:user_id])
      @user = User.find(params[:user_id])
      if @current_user.id == @user.id || (@current_user.role == "admin" && @user.role != "admin")
        if SavingsDeposit.exists?(id: params[:id], user_id: @user.id)
          @savings_deposit = SavingsDeposit.find(params[:id])
          @savings_deposit.destroy
          render json: {success_msg: "Savings deposit successfully deleted!"}
        else
          render json: {error_msgs: "Savings deposit with id: #{params[:id]} and user_id: #{params[:user_id]} doesn't exist!"}, status: :not_found
        end
      else
        render json: {error_msg: "You're not authorized to delete other user's deposits"}, status: :unauthorized
      end
    else
      render json: {error_msgs: "User with id: #{params[:user_id]} doesn't exist!"}, status: :not_found
    end
  end
  private

  def savings_deposits_params
    params.permit(:user_id,
                  :bank_name,
                  :account_number,
                  :initial_amount,
                  :start_date,
                  :end_date,
                  :interest_percentage,
                  :taxes_percentage
                 )
  end
  def admin_savings_deposits_params
    @admin_savings_deposits_params ||= params.permit(:user_id,
                                                     :bank_name,
                                                     :account_number,
                                                     :initial_amount,
                                                     :start_date,
                                                     :end_date,
                                                     :interest_percentage,
                                                     :taxes_percentage,
                                                     :new_user_id
                                                    )
  end
  
end
