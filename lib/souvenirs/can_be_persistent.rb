require "souvenirs/has_attributes"

module Souvenirs
  module CanBePersistent
    extend ActiveSupport::Concern

    included do
      unless ancestors.include?(HasAttributes)
        raise RuntimeError.new("missing mandatory module Souvenirs::HasAttributes")
      end
    end

    module ClassMethods
      def get(id)
        attributes = load_attributes_for(id)
        return nil if attributes.empty?
        new(attributes).tap do |instance|
          instance.instance_eval { @persisted = true }
        end
      end

      def get!(id)
        found = get(id)
        raise NotFound.new("id = #{id}") if found.nil?
        found
      end

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

      private

      def load_attributes_for(id)
        key_name = attributes_key_name_for(id)
        Souvenirs.driver.hgetall(key_name)
      end
    end

    module InstanceMethods
      def initialize(*args)
        super(*args)
        @persisted = false unless instance_variable_defined?(:@persisted)
      end

      def persisted?
        @persisted
      end

      def save!
        raise WriteToDbFailed unless save
        true
      end

      def save
        Souvenirs.driver.hmset(attributes_key_name, *attributes.to_a.flatten)
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
    end
  end
end
