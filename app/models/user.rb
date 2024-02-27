class User < ApplicationRecord
  has_secure_password

  validates :email, uniqueness: true

  class << self
    def authenticate(email, password)
      find_by(email: email)&.authenticate(password)
    end
  end

  def full_name
    [first_name, last_name].join(' ')
  end
end
