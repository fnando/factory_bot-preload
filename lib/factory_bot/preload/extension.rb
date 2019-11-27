# frozen_string_literal: true

module FactoryBot
  def self.preload(&block)
    Preload.preloaders << block
  end

  module Syntax
    module Default
      class DSL
        def preload(&block)
          ::FactoryBot.preload(&block)
        end
      end
    end
  end
end
