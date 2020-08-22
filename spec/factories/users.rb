FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    password_digest { 'xxxxxx' }
  end
end
