FactoryBot.define do
  factory :image do
    body { File.binread(Rails.root.join('spec/fixtures/recipe.jpg')) }
    filename { 'recipe.jpg' }
  end
end
