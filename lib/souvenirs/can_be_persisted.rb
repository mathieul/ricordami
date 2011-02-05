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
    end

    module InstanceMethods
      def initialize(*args)
        super(*args)
        @persisted = false unless instance_variable_defined?(:@persisted)
        @save_queue = []
      end

      def persisted?
        @persisted
      end

      def save!
        raise WriteToDbFailed unless save
        true
      end

      def save
        Souvenirs.driver.tap do |driver|
          driver.multi
          driver.hmset(attributes_key_name, *attributes.to_a.flatten)
          @save_queue.each { |block| block.call(self) }
          driver.exec
        end
        @persisted = true
      rescue Exception => ex
        false
      end

      def reload
        attrs = self.class.send(:load_attributes_for, id)
        load_mem_attributes(attrs) unless attrs.empty?
        self
      end

      def update_attributes!(attrs)
        update_mem_attributes!(attrs) unless attrs.empty?
        save!
        true
      end

      def update_attributes(attrs)
        update_attributes!(attrs)
      rescue Exception => ex
        false
      end

      def queue_saving_operations(&block)
        raise ArgumentError.new("missing block") unless block_given?
        raise ArgumentError.new("expecting block with 1 argument") unless block.arity == 1
        @save_queue << block
      end
    end
  end
end
