class RecipeForm
  include ActiveModel::Validations

  attr_accessor :title, :description, :steps_text, :ingredients_text, :image
  attr_reader :recipe

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 512 }
  validate :validate_steps
  validate :validate_ingredients
  validate :validate_image

  def initialize(recipe)
    # 起点になるレシピオブジェクトは保存しておく
    @recipe = recipe
    # 必要な情報をフォームにわたす
    @title = recipe.title
    @description = recipe.description
    @steps_text = StepsParser.encode(recipe.steps)
    @ingredients_text = IngredientsParser.encode(recipe.ingredients)
    @image_id = recipe.image_id
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

  def save
    return false unless valid?

    @recipe.title = @title
    @recipe.description = @description

    Recipe.transaction do
      @recipe.steps = @steps
      @recipe.ingredients = @ingredients
      if @image_uploaded
        image = Image.create!(body: @image_body, filename: @image_filename)
        @recipe.image_id = image.id
      end
      @recipe.save!
    end

    return true
  end

  # Act like ActiveRecord class
  def persisted?
    @recipe.persisted?
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
