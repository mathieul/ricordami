require "ricordami/has_attributes"

module Ricordami
  module IsPersisted
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :save_queue, :delete_queue

      def create(*args)
        new(*args).tap do |instance|
          instance.save
        end
      end

      def load_attributes_for(id)
        key_name = attributes_key_name_for(id)
        redis.hgetall(key_name)
      end

      [[:saving, :save_queue], [:deleting, :delete_queue]].each do |action, queue|
        var_name = :"@#{queue}"
        define_method(:"queue_#{action}_operations") do |&block|
          raise ArgumentError.new("missing block") unless block
          raise ArgumentError.new("expecting block with 2 arguments") unless block.arity == 2
          instance_variable_set(var_name, []) unless instance_variable_get(var_name)
          instance_variable_get(var_name) << block
        end
      end

      def redis
        @redis ||= Ricordami.driver
      end
    end

    module InstanceMethods
      def initialize(*args)
        super(*args)
        @persisted = false unless instance_variable_defined?(:@persisted)
        @deleted = false
      end

      def persisted?
        @persisted
      end

      def new_record?
        !@persisted
      end

      def deleted?
        @deleted
      end

      def save(opts = {})
        raise ModelHasBeenDeleted.new("can't save a deleted model") if deleted?
        set_initial_attribute_values if new_record?
        redis.tap do |driver|
          session = {}
          driver.multi
          driver.hmset(attributes_key_name, *attributes.to_a.flatten)
          self.class.save_queue.each { |block| block.call(self, session) } if self.class.save_queue
          driver.exec
        end
        @persisted = true
        attributes_synced_with_db!
      rescue Exception => ex
        raise ex if ex.is_a?(ModelHasBeenDeleted)
        false
      end

      def reload
        attrs = self.class.send(:load_attributes_for, id)
        update_mem_attributes(attrs) unless attrs.empty?
        attributes_synced_with_db!
        self
      end

      def update_attributes(attrs)
        raise ModelHasBeenDeleted.new("can't update the attributes of a deleted model") if deleted?
        update_mem_attributes!(attrs) unless attrs.empty?
        save
      end

      def delete
        raise ModelHasBeenDeleted.new("can't delete a model already deleted") if deleted?
        db_commands, models = [], []
        # TODO: use watch (Redis 2.2) and re-run prepare + execute if change
        session = Struct.new(:models, :commands).new(models, db_commands)
        prepare_delete(session)
        execute_delete(db_commands)
        models.each { |model| model.mark_as_deleted }
      end

      def prepare_delete(session)
        session.models << self
        session.commands << [:del, [attributes_key_name]]
        self.class.delete_queue.reverse.each { |block| block.call(self, session) } if self.class.delete_queue
      end

      def execute_delete(db_commands)
        redis.tap do |driver|
          driver.multi
          db_commands.each do |message, args|
            driver.send(message, *args)
          end
          driver.exec
        end
      end

      def mark_as_deleted
        attributes_synced_with_db!
        @deleted = true
        freeze
        true
      end

      def redis
        self.class.redis
      end
    end
  end
end
