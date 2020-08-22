class RecipesController < ApplicationController
  before_action :require_signed_in, only: %i[new edit create update destroy]

  # GET /recipes
  def index
    @recipes = Recipe.all
  end

  # GET /recipes/1
  def show
    @recipe = Recipe.find(params[:id])
  end

  # GET /recipes/new
  def new
    @recipe_form = RecipeForm.new
  end

  # GET /recipes/1/edit
  def edit
    @recipe = Recipe.find(params[:id])
    @recipe_form = RecipeForm.new(@recipe)
  end

  # POST /recipes
  def create
    @recipe_form = RecipeForm.new
    @recipe_form.apply(recipe_form_params)

    if @recipe_form.valid?
      recipe = Recipe.new(@recipe_form.to_attributes.merge(user_id: current_user.id))
      Recipe.transaction do
        if @recipe_form.image_uploaded?
          image = Image.create!(@recipe_form.to_image_attributes)
          recipe.image_id = image.id
        end
        recipe.save!
      end
      redirect_to recipe, notice: 'Recipe was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /recipes/1
  def update
    @recipe = Recipe.find(params[:id])
    @recipe_form = RecipeForm.new(@recipe)
    @recipe_form.apply(recipe_form_params)

    if @recipe_form.valid?
      Recipe.transaction do
        @recipe.steps.destroy_all
        @recipe.ingredients.destroy_all
        recipe_attrs = @recipe_form.to_attributes
        if @recipe_form.image_uploaded?
          image = Image.create!(@recipe_form.to_image_attributes)
          recipe_attrs.merge(image_id: image.id)
        end
        @recipe.update!(recipe_attrs)
      end
      redirect_to @recipe, notice: 'Recipe was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /recipes/1
  def destroy
    recipe = Recipe.find(params[:id])
    recipe.destroy
    redirect_to recipes_url, notice: 'Recipe was successfully destroyed.'
  end

  private

  # Only allow a list of trusted parameters through.
  def recipe_form_params
    params.require(:recipe).permit(:title, :description, :image, :ingredients_text, :steps_text)
  end
end
