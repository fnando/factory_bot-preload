class Skill < ActiveRecord::Base
  belongs_to :user
end if defined?(ActiveRecord)
