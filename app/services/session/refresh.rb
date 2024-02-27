module UserSession
  class Refresh
    attr_accessor :session

    def initialize(session)
      @session = session
    end

    def execute
      session.refresh!
      access_token = Jwt::AccessToken.new(session).generate
      refresh_token = Jwt::RefreshToken.new(session).generate

      {
        access_token: access_token,
        refresh_token: refresh_token,
        expires_in: Constants::ACCESS_TOKEN_TIME,
        refresh_expires_in: Constants::REFRESH_TOKEN_TIME,
        token_type: 'Bearer',
        session_state: session.id,
      }
    end
  end
end
