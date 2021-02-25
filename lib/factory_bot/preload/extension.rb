# frozen_string_literal: true

module FactoryBot
  module Syntax
    module Default
      class DSL
        def preload(&block)
          ::FactoryBot::Preload.preloaders << block
        end
      end
    end
  end
end
