=begin
Recipe
 - id (auto)
 - UUID (auto)
 - url
 - name
 - type
 - portions
 - cookingtime
 - contents
 - summary
 - imageurl
=end

class Recipe < ActiveRecord::Base
  has_many :recipeingredients
  has_many :ingredients, through: :recipeingredients

  #UUID
  before_create :check_uuid
  def check_uuid
    unless(self.uuid)
      self.uuid = SecureRandom.uuid
    end
  end
end
