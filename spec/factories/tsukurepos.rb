FactoryBot.define do
  factory :tsukurepo do
    sequence(:comment) { |n| "Tsukurepo #{n}" }
    user
    recipe
  end
end
