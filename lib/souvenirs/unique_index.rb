module Souvenirs
  VALUES_SEPARATOR = ":-:"

  class UniqueIndex
    attr_reader :owner_type, :fields, :name

    def initialize(owner_type, fields, options = {})
      #options.assert_valid_keys
      @options = options
      @owner_type = owner_type.to_s.underscore
      @fields = [fields].flatten.map(&:to_sym)
      @name = (%w(all) + @fields).join("_") + "s"
    end

    def internal_name
      @internal_name ||= "_index:#{@owner_type}:#{@name}"
    end

    def add(value)
      Souvenirs.driver.sadd(internal_name, value)
    end

    def rem(value)
      Souvenirs.driver.srem(internal_name, value)
    end

    def all
      Souvenirs.driver.smembers(internal_name)
    end

    def include?(value)
      Souvenirs.driver.sismember(internal_name, value)
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
