module Ricordami
  class Relationship
    SUPPORTED_TYPES = [:references_many, :references_one, :referenced_in]
    MANDATORY_ARGS = [:other, :self]

    attr_reader :type, :name, :object_kind, :dependent, :self_kind, :alias

    def initialize(type, options = {})
      options.assert_valid_keys(:other, :as, :self, :alias, :dependent)
      raise TypeNotSupported.new(type.to_s) unless SUPPORTED_TYPES.include?(type)
      missing = find_missing_args(options)
      raise MissingMandatoryArgs.new(missing.map(&:to_s).join(", ")) unless missing.empty?
      if options[:dependent] && ![:delete, :nullify].include?(options[:dependent])
        raise OptionValueInvalid.new(options[:dependent].to_s)
      end
      @name = options[:as] || options[:other]
      @type = type
      @object_kind = options[:other].to_s.singularize.to_sym
      @self_kind = options[:self].to_s.singularize.to_sym
      @alias = options[:alias] || options[:self]
      @dependent = options[:dependent]
    end

    def object_class
      @object_kind.to_s.camelize.constantize
    end

    def referrer_id
      return @referrer_id unless @referrer_id.nil?
      referrer = type == :referenced_in ? @name.to_s : @alias.to_s.singularize
      @referrer_id = referrer.foreign_key
    end

    private

    def find_missing_args(options)
      MANDATORY_ARGS - options.keys
    end
  end
end
