module TokenHelper
  private

  def refresh_token_rsa
    OpenSSL::PKey::RSA.new(refresh_token_private_key)
  end

  def refresh_token_private_key
    Rails.application.credentials.dig(:refresh_token_private_key)
  end
end
