=begin
Product
 - id (auto)
 - UUID (auto)
 - storechain_id
 - name (also identifier)
 - price
 - ingredient_id
 - amount
 - image_url? TODO
=end


class Product < ActiveRecord::Base
  belongs_to :storechain
  belongs_to :ingredient

  validates :name, :price, :storechain, presence: true

  #UUID
  before_create :check_uuid
  def check_uuid
    unless(self.uuid)
      self.uuid = SecureRandom.uuid
    end
  end

  before_save :update_last_updated
  def update_last_updated
    self.lastupdated = Time.now
  end

end
