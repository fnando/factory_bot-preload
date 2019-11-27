# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :skills
  has_and_belongs_to_many :categories
end
