require "souvenirs/relationship"

module Souvenirs
  module CanHaveRelationships
    extend ActiveSupport::Concern

    module ClassMethods
      def relationships
        @relationships ||= {}
      end

      Relationship::SUPPORTED_TYPES.each do |type|
        define_method(type) do |*args|
          name = args.first
          options = args[1] || {}
          self.relationships[name] = Relationship.new(type, name, options)
          send(:"create_for_#{type}", self.relationships[name])
        end
      end

      private

      def create_for_references_many(relationship)
        #raise "TODO"
      end

      def create_for_referenced_in(relationship)
        referrer_id_method = :"#{relationship.name}_id"
        attribute(referrer_id_method)
        define_method(relationship.name) do
          referrer_id = send(referrer_id_method)
          return nil if referrer_id.nil?
          klass = relationship.name.to_s.titleize.constantize
          klass.get(referrer_id)
        end
      end
    end

    module InstanceMethods
    end
  end
end
