require "ricordami/meta_field"

module Ricordami
  class Condition
    attr_reader :field, :operator, :value

    #def initialize(meta_field, value)
    def initialize(*args)
      if args[0].is_a?(Symbol)
        @field, @operator, @value = args
      else
        @field, @operator = args[0].to_a
        @value = args[1]
      end
    end
  end
end
