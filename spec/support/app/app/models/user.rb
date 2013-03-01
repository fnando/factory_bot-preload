class User < ActiveRecord::Base
  has_many :skills
end if defined?(ActiveRecord)
