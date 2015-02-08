=begin
Store
 - id (auto)
 - UUID (auto)
 - name
 - storechain_id
 - city
 - street
 - postalcode
=end


class Store < ActiveRecord::Base
  belongs_to :storechain
  has_many :openinghours
  has_many :products, through: :storechain

  validates :name, :city, :street, :postalcode, presence: true

  # currently only valid dutch adresses are allowed
  validates_format_of :city, :multiline => true, :with => /^(([2][e][[:space:]]|['][ts][-[:space:]]))?[ëéÉËa-zA-Z]{2,}((\s|[-](\s)?)[ëéÉËa-zA-Z]{2,})*$/i
  validates_format_of :postalcode, :multiline => true, :with => /^([1-9][e][\s])*([a-zA-Z]+(([\.][\s])|([\s]))?)+[1-9][0-9]*(([-][1-9][0-9]*)|([\s]?[a-zA-Z]+))?$/i
  validates_format_of :postalcode, :multiline => true, :with => /^[1-9][0-9]{3}[\s]?[A-Za-z]{2}$/i

end
