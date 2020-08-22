class TsukurepoForm
  include ActiveModel::Validations

  attr_accessor :comment, :image

  validates :comment, presence: true, length: { maximum: 255 }
  validate :validate_image

  def initialize(tsukurepo)
    @tsukurepo = tsukurepo
  end

  def apply(params)
    @comment = params[:comment]
    if params[:image].present?
      @image_uploaded = true
      @image_body = params[:image].read
      @image_filename = params[:image].original_filename
    end
  end

  def save
    return false unless valid?

    @tsukurepo.comment = @comment
    Tsukurepo.transaction do
      if @image_uploaded
        image = Image.create!(body: @image_body, filename: @image_filename)
        @tsukurepo.image_id = image.id
      end
      @tsukurepo.save!
    end

    return true
  end

  # This form used only for creation
  def persisted?
    false
  end

  # What we want is extension of filename
  private def trim_image_filename(name)
    name_len = name.size
    return name if neme_len < MAXIMUM_FILENAME_SIZE
    start_offset = name_len - MAXIMUM_FILENAME_SIZE
    name[start_offset..]
  end

  private def validate_image
    if @image_uploaded && @image_body.size > Image::MAXIMUM_FILE_SIZE
      errors.add(:image, "can't be larger than #{number_to_human_size(Image::MAXIMUM_FILE_SIZE)}.")
    end
  end
end
