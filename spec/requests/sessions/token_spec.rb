require 'rails_helper'

RSpec.describe('#token', type: :request) do
  let(:store) { create(:store, name: 'store_1') }

  let(:email) { 'ati@ati.com.tr' }
  let(:username) { 'ati_xd' }
  let(:password) { '123456' }
  let(:user) { create(:user, username: username, email: email, password: password, password_confirmation: password) }
  let(:session) { create(:session, user: user) }

  let(:access_token) { 'this_is_an_access_token' }
  let(:refresh_token) { 'this_is_a_refresh_token' }
  let(:decode_refresh_token) do
    [
      {
        'exp' => session.refresh_token_exp.to_i,
        'jti' => session.refresh_token_jti,
      },
    ]
  end

  let(:password_body) do
    {
      grant_type: 'password',
      email: email,
      password: password,
    }
  end

  let(:refresh_body) do
    {
      grant_type: 'refresh_token',
      refresh_token: refresh_token,
    }
  end

  def request(body: password_body)
    post('/sessions/token', params: body.to_json, headers: header_with_content_type)
  end

  before do
    travel_to Time.zone.local(2024, 5, 1, 12, 0)
  end

  context 'grant_type is password' do
    let(:result) do
      {
        user_session_create_result: 'user_session_create_result',
      }
    end

    it 'return result' do
      expect(UserSession::Create).to(receive_message_chain(:new, :execute).with(user).with(no_args).and_return(result))

      request

      expect(json).to(eq(result.stringify_keys))
    end

    it 'user not found' do
      password_body[:password] = 'wrong_password'

      request

      expect(json['errors']).to(be)
      expect(json['errors'][0]['code']).to(eq(10001))
    end
  end

  context 'grant_type is refresh_token' do
    let(:refresh_token_private_key) { OpenSSL::PKey::RSA.generate(512).to_s }
    let(:refresh_token_rsa) { OpenSSL::PKey::RSA.new(refresh_token_private_key) }

    let(:result) do
      {
        user_session_refresh_result: 'user_session_refresh_result',
      }
    end

    before do
      allow(OpenSSL::PKey::RSA).to(receive(:new).and_return(refresh_token_rsa))
    end

    it 'return result' do
      session
      allow(JWT).to(receive(:decode).with(refresh_token, refresh_token_rsa, true, algorithms: ['RS256']).and_return(decode_refresh_token))
      expect(UserSession::Refresh).to(receive_message_chain(:new, :execute).with(session).with(no_args).and_return(result))

      request(body: refresh_body)

      expect(json).to(eq(result.stringify_keys))
    end

    it 'session not found' do
      allow(JWT).to(receive(:decode).with(refresh_token, refresh_token_rsa, true, algorithms: ['RS256']).and_return(decode_refresh_token))
      expect(UserSession::Refresh).not_to(receive(:new))
      session.destroy!

      request(body: refresh_body)

      expect(json['errors']).to(be)
      expect(json['errors'][0]['message']).to(eq('Session not found!'))
      expect(response).to(have_http_status(404))
    end

    it 'expired signature' do
      allow(JWT).to(receive(:decode).with(refresh_token, refresh_token_rsa, true, algorithms: ['RS256']).and_raise(JWT::ExpiredSignature))

      request(body: refresh_body)

      expect(json['errors']).to(be)
      expect(json['errors'][0]['message']).to(eq('Signature has expired.'))
      expect(response).to(have_http_status(401))
    end

    it 'decode error' do
      allow(JWT).to(receive(:decode).with(refresh_token, refresh_token_rsa, true, algorithms: ['RS256']).and_raise(JWT::DecodeError))

      request(body: refresh_body)

      expect(json['errors']).to(be)
      expect(json['errors'][0]['message']).to(eq('User not authorized.'))
      expect(response).to(have_http_status(401))
    end
  end

  it 'grant_type is invalid' do
    invalid_body = {
      grant_type: 'invalid',
    }

    request(body: invalid_body)

    expect(json['errors']).to(be)
    expect(json['errors'][0]['message']).to(eq('Invalid grant type.'))
    expect(response).to(have_http_status(422))
  end
end
