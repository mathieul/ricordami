module Souvenirs
  class Attribute
    attr_reader :name

    def self.get_uuid_generator
      Proc.new { SimpleUUID::UUID.new.to_guid }
    end

    def initialize(name, options = {})
      options.assert_valid_keys(:default, :read_only, :initial)
      @options = options
      @name = name.to_s
    end

    def default_value
      return @options[:default].call if @options[:default].respond_to?(:call)
      @options[:default]
    end

    def default_value?
      @options.has_key?(:default)
    end

    def initial_value
      return @options[:initial].call if @options[:initial].respond_to?(:call)
      @options[:initial]
    end

    def initial_value?
      @options.has_key?(:initial)
    end

    def read_only?
      !!@options[:read_only]
    end
  end
end
