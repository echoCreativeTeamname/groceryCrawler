=begin
Product
 - id (auto)
 - UUID (auto) TODO: implement UUID
 - store_id
 - name (also identifier)
 - price
 - ingredient_id
 - amount
 - image_url? TODO
=end


class Product < ActiveRecord::Base
  belongs_to :storechain
  belongs_to :ingredient

end
