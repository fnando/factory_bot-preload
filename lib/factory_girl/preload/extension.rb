module Factory
  def self.preload(&block)
    Preload.preloaders << block
  end
end

module FactoryGirl
  module Syntax
    module Default
      class DSL
        def preload(&block)
          ::Factory.preload(&block)
        end
      end
    end
  end
end
