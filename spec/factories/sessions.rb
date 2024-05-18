FactoryBot.define do
  factory :session do
    user do
      FactoryBot.create(:user)
    end
  end
end
