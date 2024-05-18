require 'rails_helper'

RSpec.describe(Jwt::AccessToken, type: :service) do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }

  let(:rsa_private_key) { OpenSSL::PKey::RSA.generate(512).to_s }
  let(:rsa) { OpenSSL::PKey::RSA.new(rsa_private_key) }
  let(:kid) { Digest::SHA256.hexdigest(rsa.to_s) }

  let(:uuid) { '9c4a1c62-7494-464d-bcb7-17b9ba0d6a98' }

  subject { described_class.new(session) }

  before do
    travel_to Time.zone.local(2024, 5, 1, 12, 0)
    allow_any_instance_of(described_class).to(receive(:rsa_private_key).and_return(rsa_private_key))
    allow_any_instance_of(described_class).to(receive(:rsa).and_return(rsa))
  end

  it '#generate' do
    payload = {
      exp: 15.minutes.after.to_i,
      iat: Time.current.to_i,
      jti: uuid,
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

    allow(SecureRandom).to(receive(:uuid).and_return(uuid))
    expect(JWT).to(receive(:encode).with(payload, rsa, 'RS256', { typ: 'JWT', kid: kid }))
    subject.generate
  end

  it '#payload' do
    payload = subject.send(:payload)

    expect(payload[:exp]).to(eq(15.minutes.after.to_i))
    expect(payload[:iat]).to(eq(Time.current.to_i))
    expect(payload[:jti]).to(be)
    expect(payload[:iss]).to(eq('microservice_user_api'))
    expect(payload[:sid]).to(eq(session.id))
    expect(payload[:sub]).to(eq(user.id))
    expect(payload[:aud]).to(include('microservice_user_api_client'))
    expect(payload[:typ]).to(eq('Bearer'))
    expect(payload[:email]).to(eq(user.email))
    expect(payload[:name]).to(eq(user.full_name))
    expect(payload[:first_name]).to(eq(user.first_name))
    expect(payload[:last_name]).to(eq(user.last_name))
  end
end
