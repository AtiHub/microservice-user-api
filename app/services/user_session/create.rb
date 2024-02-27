module UserSession
  class Create
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def execute
      session = Session.create(user: user)
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
