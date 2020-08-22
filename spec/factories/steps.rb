FactoryBot.define do
  factory :step do
    recipe
    sequence(:description) { |n| "Step #{n}" }
    sequence(:position)
  end
end
