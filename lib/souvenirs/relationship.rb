module Souvenirs
  class Relationship
    SUPPORTED_TYPES = [:references_many, :referenced_in]

    attr_reader :type, :name

    def initialize(type, name, options = {})
      options.assert_valid_keys(:dependent)
      raise TypeNotSupported.new(type.to_s) unless SUPPORTED_TYPES.include?(type)
      if options[:dependent] && ![:nullify, :delete].include?(options[:dependent])
        raise OptionValueInvalid.new(options[:dependent].to_s)
      end
      @type, @name, @options = type, name, options
    end

    def dependent
      @options[:dependent]
    end
  end
end
