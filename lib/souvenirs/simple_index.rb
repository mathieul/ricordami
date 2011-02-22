require "souvenirs/namer"

module Souvenirs
  class SimpleIndex
    attr_reader :model, :field, :name

    def initialize(model, field)
      @model = model
      @field = field.to_sym
      @name = @field
    end

    def key_name_for_value(value)
      Namer.key(:index, :model => @model, :field => @field, :value => value)
    end

    def add(id, value)
      @model.redis.sadd(key_name_for_value(value), id)
    end

    def rem(id, value)
      @model.redis.srem(key_name_for_value(value), id)
    end
  end
end
