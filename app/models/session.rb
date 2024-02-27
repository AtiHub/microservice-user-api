class Session < ApplicationRecord
  belongs_to :user

  validates :refresh_token_jti, presence: true

  before_create :set_refresh_token_fields

  def refresh!
    set_refresh_token_fields
    save!
  end

  private

  def set_refresh_token_fields
    self.refresh_token_jti = SecureRandom.uuid
    self.refresh_token_exp = UserSession::Constants::REFRESH_TOKEN_TIME.seconds.after
  end
end
