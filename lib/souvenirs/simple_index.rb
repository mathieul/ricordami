require "base64"

module Souvenirs
  class SimpleIndex
    attr_reader :owner_type, :field, :name

    def initialize(owner_type, field)
      @owner_type = owner_type
      @field = field.to_sym
      @name = @field
    end

    def key_name_for_value(value)
      Factory.key_name(:index, :model => @owner_type,
                               :field => @field,
                               :value => encode(value))
    end

    def add(id, value)
      Souvenirs.driver.sadd(key_name_for_value(value), id)
    end

    def rem(id, value)
      Souvenirs.driver.srem(key_name_for_value(value), id)
    end

    private

    def encode(value)
      Base64.encode64(value.to_s).gsub("\n", "")
    end
  end
end
