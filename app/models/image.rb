class Image < ApplicationRecord
  MAXIMUM_FILE_SIZE = 10 * 1024 * 1024
  MAXIMUM_FILENAME_SIZE = 255

  validates :body, presence: true, length: { maximum: MAXIMUM_FILE_SIZE }
  validates :filename, presence: true, length: { maximum: MAXIMUM_FILENAME_SIZE }
end
