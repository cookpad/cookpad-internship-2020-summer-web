FactoryBot.define do
  factory :recipe do
    user
    sequence(:title) { |n| "Recipe #{n}" }
    sequence(:description) { |n| "Recipe #{n} description" }

    before(:create) do |recipe, _evaluator|
      recipe.steps << FactoryBot.build(:step)
      recipe.ingredients << FactoryBot.build(:ingredient)
    end
  end
end
