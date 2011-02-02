module Souvenirs
  module Connection
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def driver
        @driver ||= create_driver
      end

      private

      def create_driver
        c = self.configuration
        Redis.new(:host         => c.redis_host,
                  :port         => c.redis_port,
                  :db           => c.redis_db,
                  :thread_safe  => c.redis_thread_safe)
      end
    end
  end
end