class Artist
  include Mongoid::Document

  field :name, :type => String
end if defined?(Mongoid)

