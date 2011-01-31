module Souvenirs
  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods
      def configure(&block)
        raise ArgumentError.new("block missing") unless block_given?
        yield config
      end

      def configuration
        config
      end

      private

      def config
        @config ||= Config.new
      end
    end

    class Config
      @attributes = [:redis_host, :redis_port, :redis_db]
      @attributes.each do |attribute|
        attr_accessor attribute
      end

      private

      def method_missing(meth, *args, &blk)
        raise AttributeNotSupported.new("attribute #{meth.to_s.inspect} is not supported")
      end
    end
  end
end
