module Souvenirs
  class Index
    attr_reader :owner_type, :name

    def initialize(owner_type, name, options = {})
      #options.assert_valid_keys
      @options = options
      @name = name.to_s
      @owner_type = owner_type.to_s.underscore
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
  end
end
