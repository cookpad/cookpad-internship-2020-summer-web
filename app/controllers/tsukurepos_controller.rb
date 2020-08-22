class TsukureposController < ApplicationController
  before_action :require_signed_in, only: %i[new create destroy]

  def new
    @recipe = Recipe.find(params[:recipe_id])
    @tsukurepo_form = TsukurepoForm.new(Tsukurepo.new)
  end

  def create
    @recipe = Recipe.find(params[:recipe_id])
    @tsukurepo_form = TsukurepoForm.new(Tsukurepo.new(user_id: current_user.id, recipe_id: @recipe.id))
    @tsukurepo_form.apply(tsukurepo_form_params)
    if @tsukurepo_form.save
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
