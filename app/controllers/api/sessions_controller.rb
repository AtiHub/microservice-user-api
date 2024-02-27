class SessionsController < ApplicationController
  def token
    result = case params[:grant_type]
    when 'password'
      user = User.authenticate(params[:email]&.strip&.downcase, params[:password])
      raise Exceptions::UserNotFound unless user

      UserSession::Create.new(user).execute
    when 'refresh_token'
      @token = params[:refresh_token]
      raise Exceptions::ExpiredSignature if refresh_token_exp < Time.current.to_i

      session = Session.find_by!(refresh_token_jti: refresh_token_jti)
      UserSession::Refresh.new(session).execute
    else
      raise Exceptions::InvalidGrantType
    end

    render(json: result)
  end

  private

  def decode_refresh_token
    @decode_refresh_token ||= JWT.decode(@token, refresh_token_rsa, true, algorithms: ['RS256'])
  rescue JWT::ExpiredSignature
    raise Exceptions::ExpiredSignature
  rescue JWT::DecodeError
    raise Exceptions::UserNotAuthorized
  end

  def refresh_token_jti
    @refresh_token_jti ||= decode_refresh_token[0]['jti']
  end

  def refresh_token_exp
    @refresh_token_exp ||= decode_refresh_token[0]['exp']
  end
end
