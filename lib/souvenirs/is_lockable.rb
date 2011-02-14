module Souvenirs
  module IsLockable
    extend ActiveSupport::Concern

    module ClassMethods
      def lock
        lock!
        puts "#{Thread.current.object_id}: AFTER LOCK"
        yield
        puts "#{Thread.current.object_id}: AFTER BLOCK"
        self
      ensure
        unlock!
        puts "#{Thread.current.object_id}: AFTER UNLOCK"
      end

      private

      # see SETNX command description for more info on the locking algorithm:
      # http://redis.io/commands/setnx
      def lock!
        key = Factory.key_name(:model_lock, :model => self)
        puts "#{Thread.current.object_id}: key = #{key.inspect}"
        until Souvenirs.driver.setnx(key, Time.now.to_f + 0.5)
          puts "#{Thread.current.object_id}: ONE"
          next unless timestamp = Souvenirs.driver.get(key)
          puts "#{Thread.current.object_id}: TWO"
          sleep(0.1) and next unless lock_expired?(timestamp)
          puts "#{Thread.current.object_id}: THREE"
          break unless timestamp = Souvenirs.driver.getset(key, Time.now.to_f + 0.5)
          puts "#{Thread.current.object_id}: FOUR"
          break if lock_expired?(timestamp)
          puts "#{Thread.current.object_id}: FIVE"
        end
        puts "#{Thread.current.object_id}: SETNX => #{Souvenirs.driver.get(key)}"
        true
      end

      def unlock!
        key = Factory.key_name(:model_lock, :model => self)
        Souvenirs.driver.del(key)
      end

      def lock_expired?(timestamp)
        timestamp.to_f < Time.now.to_f
      end
    end

    module InstanceMethods
    end
  end
end
