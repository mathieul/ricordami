module Souvenirs
  class Attribute
    attr_reader :name

    def self.id_generator(model)
      key = Factory.key_name(:sequence, :type => "id", :model => model)
      Proc.new { model.redis.incr(key) }
    end

    def initialize(name, options = {})
      options.assert_valid_keys(:default, :read_only, :initial, :indexed)
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

    def indexed?
      !!@options[:indexed]
    end
  end
end
