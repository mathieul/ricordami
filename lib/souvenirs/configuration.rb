module Souvenirs
  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods
      def configure(&block)
        raise ArgumentError.new("block missing") unless block_given?
      end
    end
  end
end
