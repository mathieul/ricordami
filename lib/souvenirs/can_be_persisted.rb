require "souvenirs/has_attributes"

module Souvenirs
  module CanBePersisted
    extend ActiveSupport::Concern

    included do
      unless ancestors.include?(HasAttributes)
        raise RuntimeError.new("missing mandatory module Souvenirs::HasAttributes")
      end
    end

    module ClassMethods
      attr_reader :save_queue, :delete_queue

      def create(*args)
        new(*args).tap do |instance|
          instance.save
        end
      end

      def create!(*args)
        new(*args).tap do |instance|
          instance.save!
        end
      end

      def load_attributes_for(id)
        key_name = attributes_key_name_for(id)
        Souvenirs.driver.hgetall(key_name)
      end

      def queue_saving_operations(&block)
        raise ArgumentError.new("missing block") unless block_given?
        raise ArgumentError.new("expecting block with 1 argument") unless block.arity == 1
        (@save_queue ||= []) << block
      end

      def queue_deleting_operations(&block)
        raise ArgumentError.new("missing block") unless block_given?
        raise ArgumentError.new("expecting block with 1 argument") unless block.arity == 1
        (@delete_queue ||= []) << block
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

      def save!(opts = {})
        raise WriteToDbFailed unless save(opts)
        true
      end

      def save(opts = {})
        raise ModelHasBeenDeleted.new("can't save a deleted model") if deleted?
        set_initial_attribute_values if new_record?
        Souvenirs.driver.tap do |driver|
          driver.multi
          driver.hmset(attributes_key_name, *attributes.to_a.flatten)
          self.class.save_queue.each { |block| block.call(self) } if self.class.save_queue
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
        load_mem_attributes(attrs) unless attrs.empty?
        attributes_synced_with_db!
        self
      end

      def update_attributes!(attrs)
        raise ModelHasBeenDeleted.new("can't update the attributes of a deleted model") if deleted?
        update_mem_attributes!(attrs) unless attrs.empty?
        save!
        true
      end

      def update_attributes(attrs)
        update_attributes!(attrs)
      rescue Exception => ex
        raise ex if ex.is_a?(ModelHasBeenDeleted)
        false
      end

      def delete
        raise ModelHasBeenDeleted.new("can't delete a model already deleted") if deleted?
        Souvenirs.driver.tap do |driver|
          driver.multi
          driver.del(attributes_key_name)
          self.class.delete_queue.reverse.each { |block| block.call(self) } if self.class.delete_queue
          driver.exec
        end
        attributes_synced_with_db!
        @deleted = true
        freeze
        true
      rescue Exception => ex
        false
      end
    end
  end
end
