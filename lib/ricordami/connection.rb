module Ricordami
  module Connection
    extend ActiveSupport::Concern

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
                  :thread_safe  => c.thread_safe,
                  :timeout      => 10)
      end
    end
  end
end
