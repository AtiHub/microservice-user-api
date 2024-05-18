require 'rails_helper'

RSpec.describe(Jwt::RefreshToken, type: :service) do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }

  let(:refresh_token_private_key) { OpenSSL::PKey::RSA.generate(512).to_s }
  let(:rsa) { OpenSSL::PKey::RSA.new(refresh_token_private_key) }

  subject { described_class.new(session) }

  before do
    travel_to Time.zone.local(2024, 5, 1, 12, 0)
    allow_any_instance_of(described_class).to(receive(:rsa_private_key).and_return(refresh_token_private_key))
    allow_any_instance_of(described_class).to(receive(:rsa).and_return(rsa))
  end

  it '#generate' do
    payload = {
      exp: session.refresh_token_exp.to_i,
      iat: Time.current.to_i,
      jti: session.refresh_token_jti,
      iss: 'microservice_user_api',
      sub: user.id,
      typ: 'Bearer',
    }

    expect(JWT).to(receive(:encode).with(payload, rsa, 'RS256', { typ: 'JWT' }))
    subject.generate
  end

  it '#payload' do
    payload = subject.send(:payload)

    expect(payload[:exp]).to(eq(session.refresh_token_exp.to_i))
    expect(payload[:iat]).to(eq(Time.current.to_i))
    expect(payload[:jti]).to(eq(session.refresh_token_jti))
    expect(payload[:iss]).to(eq('microservice_user_api'))
    expect(payload[:sub]).to(eq(user.id))
    expect(payload[:typ]).to(eq('Bearer'))
  end
end
