=begin
Store
 - id (auto)
 - store_id
 - date
 - openingtime
 - closingtime
=end

class Openinghour < ActiveRecord::Base
  belongs_to :store

  validates :store, :date, :openingtime, :closingtime, presence: true
end
