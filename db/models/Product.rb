=begin
Product
 - id (auto)
 - UUID (auto)
 - store_id
 - name
 - healthclass
 - price
 - ingredient_id
 - image_url
=end


class Product < ActiveRecord::Base
  belongs_to :storechain
  belongs_to :ingredient

end
