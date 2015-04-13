module Crawler

	class Recipe

		def initialize

		end

		def findIngredientByName(name)
			#return ingredient = ::Ingredient.where(name: name).first ? ingredient | false
		end

		def findIngredientById(id)
			return ingredient = ::Ingredient.find(id) ? ingredient : false
		end

		def findIngredientByProduct(product)
			return ingredient = product.ingredient ? ingredient : false
		end

	end

end
