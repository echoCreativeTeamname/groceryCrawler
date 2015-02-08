=begin
Store
 - id (auto)
 - store_id
 - date
 - opening_time
 - closing_time
=end

class Openinghour < ActiveRecord::Base
  belongs_to :store

  validates :store_id, :date, :opening_time, :closing_time, presence: true
end
