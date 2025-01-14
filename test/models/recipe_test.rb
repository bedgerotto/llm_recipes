require "test_helper"

class RecipeTest  < ActiveSupport::TestCase
  attr_reader :recipe

  setup do
    @recipe = Recipe.new
    @recipe.assign_attributes recipe_attributes
  end

  test "Recipe has all attributes" do
    assert_equal recipe_attributes[:description], recipe.description
    assert_equal recipe_attributes[:preparation], recipe.preparation
    assert_equal recipe_attributes[:ingredients], recipe.ingredients
    assert_equal recipe_attributes[:level], recipe.level
    assert_equal recipe_attributes[:cooking_time], recipe.cooking_time
    assert_equal recipe_attributes[:valid], recipe.valid
  end

  test "Build new recipe from LLM API" do
    ingredients = %w[ ingredient-1, ingredient-2 ]
    attributes = { recipe: recipe_attributes }.deep_stringify_keys
    Groq::Repository.stubs(:generate_recipe).with(ingredients:).returns(attributes)
    recipe = Recipe.build_with(ingredients:)

    assert_equal recipe_attributes.stringify_keys, recipe.attributes
  end

  test "Use LLM to validate the recipe when the recipe is valid" do
    recipe_response = { recipe: { valid: true, reason: "some reason" } }.deep_stringify_keys
    Groq::Repository.stubs(:validate_recipe).with(recipe: recipe_attributes.stringify_keys).returns(recipe_response)

    assert_nothing_raised { recipe.validate! }
  end

  test "Use LLM to validate the recipe when the recipe isn't valid" do
    recipe_response = { recipe: { valid: false, reason: "some reason" } }.deep_stringify_keys
    Groq::Repository.stubs(:validate_recipe).with(recipe: recipe_attributes.stringify_keys).returns(recipe_response)

    assert_raises(StandardError) { recipe.validate! }
  end

  private

  def recipe_attributes
    {
      description: "this is a great recipe",
      preparation: "Step-by-step on how to prepare the dish",
      ingredients: [ "100 grams flour", "2 eggs" ],
      level: "Hard",
      cooking_time: "1 minute",
      valid: true
    }
  end
end
