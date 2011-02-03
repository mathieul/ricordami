module Souvenirs
  module CanBePersistent
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def get(id)
        key_name = attributes_key_name_for(id)
        attributes = Souvenirs.driver.hgetall(key_name)
        return nil if attributes.empty?
        new(attributes.symbolize_keys).tap do |instance|
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
    end

    module InstanceMethods
      def initialize(*args)
        super(*args)
        @persisted = false unless instance_variable_defined?(:@persisted)
      end

      def persisted?
        @persisted
      end

      def save
        Souvenirs.driver.hmset(attributes_key_name, *attributes.to_a.flatten)
        @persisted = true
      rescue Exception => ex
        false
      end

      def save!
        raise WriteToDbFailed unless save
        true
      end
    end
  end
end
