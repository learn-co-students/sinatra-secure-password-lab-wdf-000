class User < ActiveRecord::Base
  validates_presence_of :username, :password, :balance
  has_secure_password
end
