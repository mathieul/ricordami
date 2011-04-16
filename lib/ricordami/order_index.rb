require "ricordami/key_namer"

module Ricordami
  class OrderIndex
    attr_reader :model, :field, :name

    def initialize(model, field)
      @model = model
      @field = field.to_sym
      assert_numeric_field
      @name = :"o_#{@field}"
      @key_name = KeyNamer.order_index(@model, :field => @field)
    end

    def add(id, value)
      @model.redis.zadd(@key_name, value, id)
    end

    def rem(id, value, return_command = false)
      return [[:zrem, [@key_name, id]]] if return_command
      @model.redis.zrem(@key_name, id)
    end

    private

    def assert_numeric_field
      attribute = @model.attributes[@field]
      if attribute.type != :integer && attribute.type != :float
        raise TypeNotSupported.new(
          "Model #{@model}: attribute #{@field} should be an integer or a float"
        )
      end
    end
  end
end
