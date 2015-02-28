=begin
Store
 - id (auto)
 - UUID (auto)
 - name
 - storechain_id
 - city
 - street
 - postalcode
 - longitude
 - latitude
 - identifier (Unique store id for this storechain to make it easier to update it)
=end


class Store < ActiveRecord::Base
  belongs_to :chain, class_name: "Storechain"
  has_many :openinghours, dependent: :destroy
  has_many :products, through: :chain

  validates :name, :city, :street, :postalcode, :longitude, :latitude, presence: true

  # currently only valid dutch adresses are allowed
  validates_format_of :city, :multiline => true, :with => /^(([A-Za-z][A-Za-z][.][[:space:]]|[2][e][[:space:]]|['][ts][-[:space:]]))?[ëéÉËa-zA-Z\/]{2,}((\s|[-](\s)?)[ëéÉËa-zA-Z\/()]{2,})*$/i
  validates_format_of :street, :multiline => true, :with => /^([1-9][e][\s])*(['.ëéÉËa-zA-Z\-1-9]+(([\.][\s])|([\s]))?)+[1-9][0-9\-A-Za-z']*(([-][1-9][0-9]*)|([\s]?[a-zA-Z]+))?$/i
  validates_format_of :postalcode, :multiline => true, :with => /^[1-9][0-9]{3}[\s]?[A-Za-z]{2}$/i

  #UUID
  before_create :check_uuid
  def check_uuid
    unless(self.uuid)
      self.uuid = SecureRandom.uuid
    end
  end

end
