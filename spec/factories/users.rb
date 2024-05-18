FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.username }
    sequence(:email) { |n| "atakan#{n}@atakan.com" }
    password { '987654' }
    password_confirmation { '987654' }
  end
end
