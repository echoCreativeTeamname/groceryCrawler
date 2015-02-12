=begin
Recipeingredient
  - amount
  - recipe_id (auto)
  - ingredient_id (auto)
=end

class Recipeingredient < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :ingredient
  validates :amount, presence: true
end
