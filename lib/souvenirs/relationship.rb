module Souvenirs
  class Relationship
    SUPPORTED_TYPES = [:references_many, :referenced_in]

    attr_reader :type, :name, :object_kind

    def initialize(type, name, options = {})
      options.assert_valid_keys(:dependent, :as)
      raise TypeNotSupported.new(type.to_s) unless SUPPORTED_TYPES.include?(type)
      if options[:dependent] && ![:nullify, :delete].include?(options[:dependent])
        raise OptionValueInvalid.new(options[:dependent].to_s)
      end
      as = options.delete(:as)
      @name = as || name
      @type, @options = type, options
      @object_kind = name
      @object_kind = @object_kind.to_s.singularize.to_sym if @type == :references_many
    end

    def dependent
      @options[:dependent]
    end

    def object_class
      @object_kind.to_s.camelize.constantize
    end
  end
end
