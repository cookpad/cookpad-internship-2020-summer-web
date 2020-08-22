class TsukureposController < ApplicationController
  before_action :require_signed_in, only: %i[new create destroy]

  def new
    @recipe = Recipe.find(params[:recipe_id])
    @tsukurepo_form = TsukurepoForm.new
  end

  def create
    @recipe = Recipe.find(params[:recipe_id])
    @tsukurepo_form = TsukurepoForm.new
    @tsukurepo_form.apply(tsukurepo_form_params)
    if @tsukurepo_form.valid?
      tsukurepo = Tsukurepo.new(@tsukurepo_form.to_attributes.merge(user_id: current_user.id, recipe_id: @recipe.id))
      Tsukurepo.transaction do
        if @tsukurepo_form.image_uploaded?
          image = Image.create!(@tsukurepo_form.to_image_attributes)
          tsukurepo.image_id = image.id
        end
        tsukurepo.save!
      end
      redirect_to @recipe, notice: 'Tsukurepo was successfully created.'
    else
      render :new
    end
  end

  def destroy
    tsukurepo = Tsukurepo.find(params[:id])
    recipe = tsukurepo.recipe
    tsukurepo.destroy!
    redirect_to recipe, notice: 'Tsukurepo was successfully destroyed.'
  end

  private def tsukurepo_form_params
    params.require(:tsukurepo).permit(:comment, :image)
  end
end
