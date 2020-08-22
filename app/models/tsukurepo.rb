class Tsukurepo < ApplicationRecord
  belongs_to :user
  belongs_to :recipe
  belongs_to :image, dependent: :destroy, optional: true

  validates :comment, presence: true, length: { maximum: 255 }
end
