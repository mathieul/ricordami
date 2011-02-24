require "souvenirs/key_namer"

module Souvenirs
  class Attribute
    attr_reader :name

    def initialize(name, options = {})
      options.assert_valid_keys(:default, :read_only, :initial, :indexed)
      if options[:indexed] && ![:value, :unique].include?(options[:indexed])
        raise InvalidIndexDefinition.new(options[:indexed].to_s)
      end
      @options = options
      @name = name.to_sym
    end

    [:default, :initial].each do |name|
      define_method(:"#{name}_value") do
        return @options[name].call if @options[name].respond_to?(:call)
        @options[name]
      end

      define_method(:"#{name}_value?") do
        @options.has_key?(name)
      end
    end

    def read_only?
      !!@options[:read_only]
    end

    def indexed
      @options[:indexed]
    end

    def indexed?
      !!@options[:indexed]
    end
  end
end
