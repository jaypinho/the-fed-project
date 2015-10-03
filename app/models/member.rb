class Member < ActiveRecord::Base
  has_many :statements
  has_many :terms
end
