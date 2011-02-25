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
        end
      end
    end

    module InstanceMethods
    end
  end
end
