module Ricordami
  module Connection
    extend ActiveSupport::Concern

    module ClassMethods
      def redis
        @redis ||= create_redis
      end

      private

      def create_redis
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
