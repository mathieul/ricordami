module Souvenirs
  class UniqueIndex
    SEPARATOR = "_-::-_"

    attr_reader :owner_type, :fields, :name, :need_get_by

    def initialize(owner_type, fields, options = {})
      @owner_type = owner_type
      @fields = [fields].flatten.map(&:to_sym)
      @need_get_by = options[:get_by] && @fields != [:id]
      @name = (%w(all) + @fields).join("_") + "s"
      @name = @name.to_sym
    end

    def uidx_key_name
      @uidx_key_name ||= Factory.key_name(:unique_index,
                                          :model => @owner_type,
                                          :name => @name)
    end

    def ref_key_name
      @ref_key_name ||= Factory.key_name(:hash_ref,
                                         :model => @owner_type,
                                         :fields => @fields)
    end

    def add(id, value)
      value = value.join(SEPARATOR) if value.is_a?(Array)
      Souvenirs.driver.sadd(uidx_key_name, value)
      Souvenirs.driver.hset(ref_key_name, value, id) if @need_get_by
    end

    def rem(id, value)
      Souvenirs.driver.hdel(ref_key_name, id) if @need_get_by
      value = value.join(SEPARATOR) if value.is_a?(Array)
      Souvenirs.driver.srem(uidx_key_name, value)
    end

    def id_for_values(*values)
      values = values.flatten.join(SEPARATOR)
      Souvenirs.driver.hget(ref_key_name, values)
    end

    def all
      Souvenirs.driver.smembers(uidx_key_name)
    end

    def count
      Souvenirs.driver.scard(uidx_key_name)
    end

    def include?(value)
      Souvenirs.driver.sismember(uidx_key_name, value)
    end
  end
end
