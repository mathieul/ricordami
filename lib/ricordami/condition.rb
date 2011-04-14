require "ricordami/meta_field"

module Ricordami
  class Condition
    attr_reader :field, :operator, :value

    def initialize(meta_field, value)
      @field, @operator = meta_field.to_a
      @value = value
    end
  end
end
