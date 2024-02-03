require 'rails_helper'

RSpec.describe(User, type: :model) do
  context 'Validations' do
    it { expect validate_uniqueness_of(:email) }
  end
end
