require "ricordami/key_namer"

module Ricordami
  class UniqueIndex
    SEPARATOR = "_-::-_"

    attr_reader :model, :fields, :name, :need_get_by, :scope

    def initialize(model, fields, options = {})
      @model = model
      @fields = normalize_array(fields)
      @name = @fields.join("_").to_sym
      @need_get_by = options[:get_by] && @fields != [:id]
      if options.has_key?(:scope)
        @scope = normalize_array(options[:scope])
        @fields.push(*@scope)
      end
    end

    def uidx_key_name
      @uidx_key_name ||= KeyNamer.unique_index(@model, :name => @name)
    end

    def ref_key_name
      @ref_key_name ||= KeyNamer.hash_ref(@model, :fields => @fields)
    end

    def add(id, value)
      value = normalize_value(value)
      @model.redis.sadd(uidx_key_name, value)
      @model.redis.hset(ref_key_name, value, id) if @need_get_by
    end

    def rem(id, value, return_command = false)
      if return_command
        commands = []
        commands << [:hdel, [ref_key_name, id]] if @need_get_by
        commands << [:srem, [uidx_key_name, value]]
        return commands
      end
      @model.redis.hdel(ref_key_name, id) if @need_get_by
      value = normalize_value(value)
      @model.redis.srem(uidx_key_name, value)
    end

    def id_for_values(*values)
      values = values.flatten.join(SEPARATOR)
      @model.redis.hget(ref_key_name, values)
    end

    def all
      @model.redis.smembers(uidx_key_name)
    end

    def count
      @model.redis.scard(uidx_key_name)
    end

    def include?(value)
      @model.redis.sismember(uidx_key_name, value)
    end

    def normalize_value(value)
      value.is_a?(Array) ? value.join(SEPARATOR) : value
    end

    private

    def normalize_array(array)
      return [] if array.nil?
      [array].flatten.map(&:to_sym)
    end
  end
end
