require "ricordami/meta_field"

module Ricordami
  class Condition
    attr_reader :field, :operator, :value

    #def initialize(meta_field, value)
    def initialize(*args)
      if args[0].is_a?(Symbol)
        @field = args.shift
        @operator = args.length == 2 ? args.shift : :eq
        @value = args.first
      else
        @field, @operator = args[0].to_a
        @value = args[1]
      end
    end

    def ==(other)
      @field == other.field &&
        @operator == other.operator &&
        @value == other.value
    end
  end
end
