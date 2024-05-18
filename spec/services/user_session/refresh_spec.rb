require 'rails_helper'

RSpec.describe(UserSession::Refresh, type: :service) do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }

  subject { described_class.new(session) }

  before do
    travel_to Time.zone.local(2024, 5, 1, 12, 0)
  end

  it '#execute' do
    expect(session).to(receive(:refresh!).and_call_original)
    expect(Jwt::AccessToken).to(receive_message_chain(:new, :generate).with(session).with(no_args).and_return('access_token'))
    expect(Jwt::RefreshToken).to(receive_message_chain(:new, :generate).with(session).with(no_args).and_return('refresh_token'))

    result = subject.execute

    expect(result[:access_token]).to(eq('access_token'))
    expect(result[:refresh_token]).to(eq('refresh_token'))
    expect(result[:expires_in]).to(eq(UserSession::Constants::ACCESS_TOKEN_TIME))
    expect(result[:refresh_expires_in]).to(eq(UserSession::Constants::REFRESH_TOKEN_TIME))
    expect(result[:token_type]).to(eq('Bearer'))
    expect(result[:session_state]).to(eq(session.id))
  end
end
