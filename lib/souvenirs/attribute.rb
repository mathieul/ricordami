module Souvenirs
  class Attribute
    attr_reader :name

    def initialize(name, options = {})
      options.assert_valid_keys(:default, :read_only)
      @options = options
      @name = name.to_s
    end

    def default_value
      return @options[:default].call if @options[:default].respond_to?(:call)
      @options[:default]
    end

    def read_only?
      !!@options[:read_only]
    end
  end
end
