class AuthenticationToken < ActiveRecord::Base
  belongs_to :user

  validates :user, :valid_till,  presence: true

  #Token
  before_create :set_token
  def set_token
    unless(self.token)
      self.token = SecureRandom.uuid
    end
  end

end
