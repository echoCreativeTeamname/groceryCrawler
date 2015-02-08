=begin
Recipe
 - id (auto)
 - url
 - name
 - summary
 - imageurl
=end

class Recipe < ActiveRecord::Base
  has_many :recipeingredients
  has_many :ingredients, through: :recipeingredients
end
