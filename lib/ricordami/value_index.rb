require "ricordami/key_namer"

module Ricordami
  class ValueIndex
    attr_reader :model, :field, :name

    def initialize(model, field)
      @model = model
      @field = field.to_sym
      @name = :"v_#{@field}"
    end

    def key_name_for_value(value)
      KeyNamer.value_index(@model, :field => @field, :value => value)
    end

    def add(id, value)
      @model.redis.sadd(key_name_for_value(value), id)
    end

    def rem(id, value, return_command = false)
      return [[:srem, [key_name_for_value(value), id]]] if return_command
      @model.redis.srem(key_name_for_value(value), id)
    end
  end
end
