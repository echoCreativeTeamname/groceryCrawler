require 'date'

=begin
Storechain
  - id (auto)
  - UUID (auto)
  - name
  - healthclass
  - priceclass
  - lastupdated
=end
class Storechain < ActiveRecord::Base

  has_many :stores, dependent: :destroy, :foreign_key => 'chain_id'
  has_many :products, dependent: :destroy
  validates :name, presence: true

  before_save :update_last_updated

  def updated()
    self.lastupdated = Time.now
    self.save
  end

  def lastUpdatedDate
    DateTime.strptime(self.lastupdated.to_s,'%s')
  end

  #UUID
  before_create :check_uuid
  def check_uuid
    unless(self.uuid)
      self.uuid = SecureRandom.uuid
    end
  end

  private
  def update_last_updated
    self.lastupdated = Time.now unless(self.lastupdated)
  end

end
