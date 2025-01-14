module Groq
  class Repository
    class << self
      def generate_recipe(ingredients:)
        response = client.get_recipe(ingredients:)

        handle_response response
      end

      def validate_recipe(recipe:)
        response = client.get_validate_recipe(recipe:)

        handle_response response
      end

      private

      def client
        Groq::Client.instance
      end

      def handle_response(response)
        raise StandardError.new("Request failed with #{response.message}") unless response.code.starts_with? "2"

        parsed_body = JSON.parse(response.body)
        answer = parsed_body["choices"].first

        JSON.parse answer.dig("message", "content")
      end
    end
  end
end
