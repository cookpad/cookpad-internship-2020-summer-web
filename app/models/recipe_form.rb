class RecipeForm
  include ActiveModel::Validations

  attr_accessor :title, :description, :steps_text, :ingredients_text, :image

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 512 }
  validate :validate_steps
  validate :validate_ingredients
  validate :validate_image

  def initialize(model = nil)
    if model
      @title = model.title
      @description = model.description
      @steps_text = StepsParser.encode(model.steps)
      @ingredients_text = IngredientsParser.encode(model.ingredients)
      @image_id = model.image_id
      @persisted = model.persisted?
    else
      @persisted = false
    end
    @image_uploaded = false
  end

  def apply(params)
    @title = params[:title]
    @description = params[:description]
    if params[:image].present?
      @image_uploaded = true
      @image_body = params[:image].read
      @image_filename = params[:image].original_filename
    end
    @steps_text = params[:steps_text]
    @ingredients_text = params[:ingredients_text]
  end

  def persisted?
    @persisted
  end

  def to_attributes
    {
      title: @title,
      description: @description,
      steps_attributes: @steps.map(&:attributes),
      ingredients_attributes: @ingredients.map(&:attributes),
    }
  end

  def to_image_attributes
    { body: @image_body, filename: @image_filename }
  end

  def image_uploaded?
    @image_uploaded
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

  private def validate_steps
    @steps = StepsParser.parse(@steps_text)
    unless @steps.size > 0
      errors.add(:steps_text, 'has more than 1 step.')
    end
  end

  private def validate_ingredients
    @ingredients = IngredientsParser.parse(@ingredients_text)
    unless @ingredients.size > 0
      errors.add(:ingredients_text, 'has more than 1 ingredient.')
    end
  rescue IngredientsParser::ParseError => e
    errors.add(:ingredients_text, e.message)
  end
end
