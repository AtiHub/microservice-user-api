module Jwt
  class RefreshToken
    attr_accessor :user, :session

    def initialize(session)
      @session = session
      @user = session.user
    end

    def generate
      JWT.encode(payload, rsa, 'RS256', { typ: 'JWT' })
    end

    private

    def payload
      {
        exp: session.refresh_token_exp,
        iat: Time.current.to_i,
        jti: session.refresh_token_jti,
        iss: 'microservice_user_api',
        sub: user.id,
        typ: 'Bearer',
      }
    end

    def rsa
      OpenSSL::PKey::RSA.new(rsa_private_key)
    end

    def rsa_private_key
      Rails.application.credentials.dig(:refresh_token_private_key)
    end
  end
end
