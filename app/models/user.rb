class User < ApplicationRecord
  has_secure_password

  validates :email, uniqueness: true

  def self.authenticate(email, password)
    find_by(email: email)&.authenticate(password)
  end
end
