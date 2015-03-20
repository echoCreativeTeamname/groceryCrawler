=begin
Ingredient
 - id (auto)
 - UUID (auto)
 - name
 - healthclass
 -
=end

class Ingredient < ActiveRecord::Base
  has_many :recipeingredients
  has_many :products
  has_many :recipes, through: :recipeingredients

  #UUID
  before_create :check_uuid
  def check_uuid
    unless(self.uuid)
      self.uuid = SecureRandom.uuid
    end
  end
end
