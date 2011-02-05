require "souvenirs/can_be_persisted"
require "souvenirs/has_indices"

module Souvenirs
  module CanBeQueried
    extend ActiveSupport::Concern

    included do
      unless ancestors.include?(CanBePersisted)
        raise RuntimeError.new("missing mandatory module Souvenirs::CanBePersisted")
      end
      index :unique => :id
      #queue_saving_operations do |obj|
        #indices[:all_ids].add(obj.id) unless obj.persisted?
      #end
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
    end
  end
end
