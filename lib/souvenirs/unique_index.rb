module Souvenirs
  VALUES_SEPARATOR = ":-:"

  class UniqueIndex
    attr_reader :owner_type, :fields, :name, :need_get_by

    def initialize(owner_type, fields, options = {})
      @owner_type = owner_type.to_s.underscore
      @fields = [fields].flatten.map(&:to_sym)
      @need_get_by = options[:get_by] && @fields != [:id]
      @name = (%w(all) + @fields).join("_") + "s"
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
      value = value.join(VALUES_SEPARATOR) if value.is_a?(Array)
      Souvenirs.driver.sadd(uidx_key_name, value)
      Souvenirs.driver.hset(ref_key_name, value, id) if @need_get_by
    end

    def rem(id, value)
      Souvenirs.driver.hdel(ref_key_name, id) if @need_get_by
      value = value.join(VALUES_SEPARATOR) if value.is_a?(Array)
      Souvenirs.driver.srem(uidx_key_name, value)
    end

    def id_for_values(*values)
      values = values.flatten.join(VALUES_SEPARATOR)
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

    def package_fields(obj, opts = {})
      opts[:for_deletion] ? \
        serialize_persisted(obj, opts) : serialize_changed(obj, opts)
    end

    private

    def serialize_persisted(obj, opts)
      values = fields.map do |field|
        obj.send("#{field}_was")
      end
      values.compact.empty? ? nil : values.join(VALUES_SEPARATOR)
    end

    def serialize_changed(obj, opts)
      changed = fields.map { |field| obj.send("#{field}_changed?") }
      return nil unless changed.any?
      values = fields.map do |field|
        if opts[:previous_value]
          obj.send("#{field}_was")
        else
          obj.send(field)
        end
      end
      values.join(VALUES_SEPARATOR)
    end
  end
end
