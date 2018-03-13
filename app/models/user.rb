class User < ApplicationRecord
  has_many :savings_deposits, dependent: :destroy
  has_secure_password
  attr_accessor :activation_token
  after_create :add_activation_digest
  enum role: [:user, :user_manager, :admin]
  validates_presence_of :name, :email, :password_digest
  validates :email, uniqueness: true

  def as_json(options={})
    super(:only => [:id, :name, :email, :role])
  end
  
  private
  
  def add_activation_digest
    self.activation_token = SecureRandom.urlsafe_base64
    activation_digest = BCrypt::Password.create(activation_token)
    update_attribute(:activation_digest, activation_digest)
  end
end
