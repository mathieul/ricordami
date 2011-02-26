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
        referrer_var = :"@#{relationship.name}"
        # declare referrer method
        define_method(relationship.name) do
          referrer = instance_variable_get(referrer_var)
          return referrer unless referrer.nil?
          referrer_id = send(referrer_id_method)
          return nil if referrer_id.nil?
          klass = relationship.name.to_s.titleize.constantize
          klass.get(referrer_id).tap do |referrer|
            instance_variable_set(referrer_var, referrer)
          end
        end
        # overide referrer id to sweep cache
        define_method(:"#{relationship.name}_id=") do |value|
          instance_variable_set(referrer_var, nil)
          super(value)
        end
      end
    end

    module InstanceMethods
    end
  end
end
