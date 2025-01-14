class Recipe
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

  attribute :description, :string
  attribute :preparation, :string
  attribute :ingredients, array: true
  attribute :level, :string
  attribute :cooking_time, :string
  attribute :valid, :boolean

  class << self
    def build_with(ingredients:)
      result = Groq::Repository.generate_recipe(ingredients:)

      record = new
      record.assign_attributes result["recipe"]
      record
    end
  end

  def validate!
    result = Groq::Repository.validate_recipe(recipe: attributes)
    self.valid = result.dig("recipe", "valid")

    raise StandardError.new "Invalid Recipe" unless valid
  end
end
