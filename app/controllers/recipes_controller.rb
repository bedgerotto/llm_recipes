class RecipesController < ApplicationController
  def index; end

  def generate
    recipe = Recipe.build_with(ingredients: permitted_params)
    recipe.validate!

    render json: { recipe: recipe.attributes }
  end

  private

  def permitted_params
    params.require(:recipe).permit(:ingredients)
  end
end
