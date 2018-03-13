class AuthenticateUser
  prepend SimpleCommand

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_accessor :email, :password

  def user
    user = User.find_by_email(email)
    if user && user.authenticate(password) && user.activated
      return user
    elsif !user
      errors.add :user_authentication, 'Invalid email!'
      return nil
    elsif !user.authenticate(password)
      errors.add :user_authentication, 'Invalid password!'
      return nil
    elsif !user.activated
      errors.add :user_authentication, 'Account not activated yet!'
    end
  end
end
