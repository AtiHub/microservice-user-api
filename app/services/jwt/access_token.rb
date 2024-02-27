module Jwt
  class AccessToken
    attr_accessor :user, :session

    def initialize(session)
      @session = session
      @user = session.user
    end

    def generate
      JWT.encode(payload, rsa, 'RS256', { typ: 'JWT', kid: kid })
    end

    private

    def payload
      {
        exp: 15.minutes.after.to_i,
        iat: Time.current.to_i,
        jti: SecureRandom.uuid,
        iss: 'microservice_user_api',
        sid: session.id,
        sub: user.id,
        aud: ['microservice_user_api_client'],
        typ: 'Bearer',
        email: user.email,
        name: user.full_name,
        first_name: user.first_name,
        last_name: user.last_name,
      }
    end

    def rsa
      OpenSSL::PKey::RSA.new(rsa_private_key)
    end

    def kid
      Digest::SHA256.hexdigest(rsa.to_s)
    end

    def rsa_private_key
      Rails.application.credentials.dig(:rsa_private_key)
    end
  end
end
