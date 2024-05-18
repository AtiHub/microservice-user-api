require 'rails_helper'

RSpec.describe(Session, type: :model) do
  context 'Associations' do
    it { is_expected.to(belong_to(:user)) }
  end

  context 'Validations' do
    it { expect validate_presence_of(:refresh_token_jti) }
    it { expect validate_presence_of(:refresh_token_exp) }
  end

  context 'Methods' do
    it '#refresh!' do
      session = create(:session)

      expect do
        session.refresh!
        session.reload
      end.to(change { session.refresh_token_jti }
        .and(change { session.refresh_token_exp }))
    end
  end
end
