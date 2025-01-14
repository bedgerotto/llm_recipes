require "net/http"
require "uri"

module Groq
  class Client
    include Singleton

    attr_accessor :llm_model_id

    def initialize
      @api_key = ENV["GROQ_API_KEY"]
      @api_base_url = ENV["GROQ_API_BASE_URL"]
      @completions_uri = URI(ENV["GROQ_API_BASE_URL"] + "/openai/v1/chat/completions")
      @headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{api_key}"
      }
      @llm_model_id = "llama-3.3-70b-versatile"
    end

    def get_recipe(ingredients:)
      body = build_recipe_body_request_for(ingredients:)

      Net::HTTP.post(completions_uri, body, headers)
    end

    def get_validate_recipe(recipe:)
      body = build_recipe_validation_body_for(recipe:)

      Net::HTTP.post(completions_uri, body, headers)
    end

    private

    attr_reader :api_key, :api_base_url, :headers, :completions_uri

    def build_recipe_body_request_for(ingredients:)
      message_with_ingredients = [
        {
          role: "user",
          content: "Provide me with a recipe that can be built using the following ingredients: #{ingredients}"
        }
      ]

      {
        messages: generate_recipe_request_prime + message_with_ingredients,
        model: llm_model_id,
        response_format: { type: "json_object" }
      }.to_json
    end

    def build_recipe_validation_body_for(recipe:)
      message_with_recipe = [
        {
          role: "user",
          content: "Check if the following recipe is a valid and actual recipe: #{recipe}"
        }
      ]

      {
        messages: validate_recipe_request_prime + message_with_recipe,
        model: llm_model_id
      }.to_json
    end

    def generate_recipe_request_prime
      [
        {
          role: "system",
          content: "I am a kitchen assistant who can create recipes with any list of ingredients"
        },
        {
          role: "system",
          content: "Always provide ingredients with quantities and measure units"
        },
        {
          role: "system",
          content: "Reply with JSON. Use the following structure in the response: #{sample_json_recipe}"
        },
        {
          role: "system",
          content: "If any non edible ingredient is provided, use the following structure in the response: #{sample_json_validation}"
        },
        {
          role: "system",
          content: "If the input isn't a valid list of ingredients, use the following structure in the response without any other explanation text: #{sample_json_validation}"
        }
      ]
    end

    def validate_recipe_request_prime
      [
        {
          role: "system",
          content: "I am a kitchen assistant who can create recipes with any list of ingredients"
        },
        {
          role: "system",
          content: "Reply with JSON. Use the following structure in the response: #{sample_json_validation}"
        },
        {
          role: "system",
          content: "If the input isn't a valid recipe, use the following structure in the response without any other explanation text: #{sample_json_validation}"
        }
      ]
    end

    def sample_json_recipe
      {
        recipe: {
          description: "this is a great recipe",
          preparation: "Step-by-step on how to prepare the dish",
          ingredients: [ "100 grams flour", "2 eggs" ],
          level: "Hard",
          cooking_time: "1 minute",
          valid: true
        }
      }.to_json
    end

    def sample_json_validation
      { recipe: { valid: false, reason: "Some useful message for the user" } }.to_json
    end
  end
end
