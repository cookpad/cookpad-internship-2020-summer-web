class Ingredient < ApplicationRecord
  MAX_NAME_LENGTH = 255
  MAX_QUANTITY_LENGTH = 255

  belongs_to :recipe

  validates :name, presence: true, length: { maximum: MAX_NAME_LENGTH }
  validates :quantity, presence: true, length: { maximum: MAX_QUANTITY_LENGTH }
  validates :position, presence: true
end
