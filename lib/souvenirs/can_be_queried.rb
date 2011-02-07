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
    end

    module ClassMethods
      def get(id)
        attributes = load_attributes_for(id)
        raise NotFound.new("id = #{id}") if attributes.empty?
        new(attributes).tap do |instance|
          instance.instance_eval do
            @persisted = true
            attributes_synced_with_db!
          end
        end
      end
      alias :[] :get

      def all
        ids = indices[:all_ids].all
        ids.map { |id| get(id) }
      end
    end

    module InstanceMethods
    end
  end
end
