require "souvenirs/relationship"
require "souvenirs/can_be_queried"

module Souvenirs
  module CanHaveRelationships
    extend ActiveSupport::Concern

    included do |base|
      base.send(:include, CanBeQueried)
    end

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
        referrer_id = :"#{relationship.name}_id"
        attribute(referrer_id)
        index(:value => :computer_id)
        create_referrer_method(relationship.name)
        overide_referrer_id(relationship.name)
      end

      def create_referrer_method(name)
        referrer_var = :"@#{name}"
        # declare referrer method
        define_method(name) do
          referrer = instance_variable_get(referrer_var)
          return referrer unless referrer.nil?
          referrer_id = send(:"#{name}_id")
          return nil if referrer_id.nil?
          klass = name.to_s.titleize.constantize
          klass.get(referrer_id).tap do |referrer|
            instance_variable_set(referrer_var, referrer)
          end
        end
      end

      def overide_referrer_id(name)
        referrer_var = :"@#{name}"
        # overide referrer id to sweep cache
        define_method(:"#{name}_id=") do |value|
          instance_variable_set(referrer_var, nil)
          super(value)
        end
      end
    end

    module InstanceMethods
    end
  end
end
