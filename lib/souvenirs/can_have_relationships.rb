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
          send(:"create_methods_for_#{type}", self.relationships[name])
        end
      end

      private

      def create_methods_for_references_many(relationship)
        #raise "TODO"
      end

      def create_methods_for_referenced_in(relationship)
        #raise "TODO"
      end
    end

    module InstanceMethods
    end
  end
end
