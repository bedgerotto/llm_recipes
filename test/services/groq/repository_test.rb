require "test_helper"

Response = Struct.new(:code, :body, :message)

module Groq
  class RepositoryTest  < ActiveSupport::TestCase
    test "generate_recipe calls the client and parses the response" do
      ingredients = %w[ ingredient-1, ingredient-2 ]
      client.stubs(:get_recipe).with(ingredients:).returns(generate_recipe_response)

      result = Repository.generate_recipe(ingredients:)

      assert_equal recipe_attributes.stringify_keys, result["recipe"]
    end

    test "generate_recipe receives failure response from client" do
      ingredients = %w[ ingredient-1, ingredient-2 ]
      client.stubs(:get_recipe).with(ingredients:).returns(generate_recipe_failure_response)

      assert_raises StandardError do
        Repository.generate_recipe(ingredients:)
      end
    end

    private

    def client
      Groq::Client.instance
    end

    def generate_recipe_failure_response
      Response.new("400", {}, "Bad request")
    end

    def generate_recipe_response
      Response.new("200", {
        choices: [
          message: {
            content: {
              recipe: recipe_attributes
            }.to_json
          }
        ]
      }.to_json, "")
    end

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
end
