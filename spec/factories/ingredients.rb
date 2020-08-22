FactoryBot.define do
  factory :ingredient do
    recipe
    sequence(:name) { |n| "name #{n}" }
    sequence(:quantity) { |n| "quantity #{n}" }
    sequence(:position)
  end
end
