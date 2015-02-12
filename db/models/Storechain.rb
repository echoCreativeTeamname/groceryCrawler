require 'date'

=begin
Storechain
  - id (auto)
  - name
  - healthclass
  - priceclass
  - lastupdated
=end
class Storechain < ActiveRecord::Base

  has_many :stores
  has_many :products
  validates :name, presence: true

  before_save :update_last_updated

  def updated()
    self.lastupdated = Time.now
    self.save
  end

  def lastUpdatedDate
    DateTime.strptime(self.lastupdated.to_s,'%s')
  end

  private
  def update_last_updated
    self.lastupdated = Time.now unless(self.lastupdated)
  end

end
