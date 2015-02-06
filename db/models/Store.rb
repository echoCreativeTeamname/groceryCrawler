
class Store < ActiveRecord::Base
  belongs_to :storechain
  has_many :openinghours
  has_many :products

  validates :name, presence: true

end
