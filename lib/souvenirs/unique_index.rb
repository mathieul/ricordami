module Souvenirs
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

    def package_fields(obj)
      fields.map { |field| obj.send(field) }.join(":-:")
    end
  end
end
