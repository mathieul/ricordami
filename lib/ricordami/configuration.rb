module Ricordami
  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods
      def configure(&block)
        raise ArgumentError.new("block missing") unless block_given?
        yield configuration
      end

      def configuration
        @configuration ||= Config.new
      end
    end
  end

  class Config
    ATTRIBUTE_NAMES = [:redis_host, :redis_port, :redis_db, :thread_safe]

    def initialize
      @options = {}
    end

    def from_hash(options)
      @options = options.slice(*ATTRIBUTE_NAMES)
    end

    private

    def method_missing(meth, *args, &blk)
      return @options[meth] if ATTRIBUTE_NAMES.include?(meth)
      if args.length == 1 && match = /^(.*)=$/.match(meth.to_s)
        name = match[1].to_sym
        return @options[name] = args.first if ATTRIBUTE_NAMES.include?(name)
      end
      raise AttributeNotSupported.new("attribute #{meth.to_s.inspect} is not supported")
    end
  end
end
