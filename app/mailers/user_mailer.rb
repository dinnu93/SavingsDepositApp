class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'
  def send_activation_link(user)
    @user = user
    mail to: @user.email, subject: 'Account activation'
  end
end
