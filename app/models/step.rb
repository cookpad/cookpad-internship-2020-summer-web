class Step < ApplicationRecord
  MAX_DESCRIPTION_LENGTH = 255

  belongs_to :recipe

  validates :description, presence: true, length: { maximum: MAX_DESCRIPTION_LENGTH }
  validates :position, presence: true
end
