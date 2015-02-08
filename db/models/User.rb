=begin
User
 - id (auto)
 - UUID (auto)

=end

class User < ActiveRecord::Base

  validates :email, :password,  presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

end
