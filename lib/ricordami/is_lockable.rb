require "ricordami/key_namer"

module Ricordami
  module IsLockable
    extend ActiveSupport::Concern

    module InstanceMethods
      # Pretty much stolen from redis objects
      # http://github.com/nateware/redis-objects/blob/master/lib/redis/lock.rb
      def lock!(options = {}, &block)
        key           = KeyNamer.lock(self.class, :id => id)
        start         = Time.now
        acquired_lock = false
        expiration    = nil
        expires_in    = options.fetch(:expiration, 15)
        timeout       = options.fetch(:timeout, 1)

        while (Time.now - start) < timeout
          expiration    = generate_expiration(expires_in)
          acquired_lock = redis.setnx(key, expiration)
          break if acquired_lock

          old_expiration = redis.get(key).to_f

          if old_expiration < Time.now.to_f
            expiration     = generate_expiration(expires_in)
            old_expiration = redis.getset(key, expiration).to_f

            if old_expiration < Time.now.to_f
              acquired_lock = true
              break
            end
          end

          sleep 0.1
        end

        raise(LockTimeout.new(key, timeout)) unless acquired_lock

        begin
          yield
        ensure
          redis.del(key) if expiration > Time.now.to_f
        end
      end

      def generate_expiration(expiration)
        (Time.now + expiration.to_f).to_f
      end
    end
  end
end
