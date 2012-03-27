module FactoryGirl
  def self.preload(&block)
    Preload.preloaders << block
  end

  module Syntax
    module Default
      class DSL
        def preload(&block)
          ::FactoryGirl.preload(&block)
        end
      end
    end
  end
end
