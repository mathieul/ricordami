require "souvenirs/can_be_persisted"
require "souvenirs/has_indices"

module Souvenirs
  module CanBeQueried
    extend ActiveSupport::Concern

    included do
      unless ancestors.include?(CanBePersisted)
        raise RuntimeError.new("missing mandatory module Souvenirs::CanBePersisted")
      end
      index :all_ids
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
        get(id).tap do |found|
          raise NotFound.new("id = #{id}") if found.nil?
        end
      end

      def all
        ids = indices[:all_ids].all
        ids.map { |id| get(id) }
      end
    end

    module InstanceMethods
      def initialize(*args)
        super(*args)
        queue_saving_operations do |obj|
          self.class.indices[:all_ids].add(id) unless obj.persisted?
        end
      end
    end
  end
end
