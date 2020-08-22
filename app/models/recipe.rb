class Recipe < ApplicationRecord
  has_many :steps, dependent: :destroy
  has_many :ingredients, dependent: :destroy
  has_many :tsukurepos, dependent: :destroy

  belongs_to :user
  belongs_to :image, dependent: :destroy, optional: true

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 512 }
end
