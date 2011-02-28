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
          relationship = Relationship.new(type, name, options)
          self.relationships[relationship.name] = relationship
          setup_method = :"setup_#{type}"
          send(setup_method, relationship) if respond_to?(setup_method, true)
        end
      end

      private

      def lazy_setup_references_many(relationship)
        klass = relationship.object_class
        referrer_id = :"#{self.to_s.underscore}_id"
        define_method(relationship.name) do
          return Query.new([], klass) unless persisted?
          klass.where(referrer_id => self.id)
        end
        if relationship.dependent == :delete
          queue_deleting_operations do |obj, session|
            referenced_objects = obj.send(relationship.name)
            referenced_objects.each do |referenced_object|
              referenced_object.prepare_delete(session)
            end
          end
        end
      end

      def setup_referenced_in(relationship)
        referrer_id = :"#{relationship.name}_id"
        attribute(referrer_id, :indexed => :value)
        overide_referrer_id_reader(relationship.name)
      end

      def lazy_setup_referenced_in(relationship)
        klass = relationship.object_class
        name = relationship.name
        referrer_var = :"@#{name}"
        define_method(name) do
          referrer = instance_variable_get(referrer_var)
          return referrer unless referrer.nil?
          referrer_id = send(:"#{name}_id")
          return nil if referrer_id.nil?
          klass.get(referrer_id).tap do |referrer|
            instance_variable_set(referrer_var, referrer)
          end
        end
      end

      def overide_referrer_id_reader(name)
        referrer_var = :"@#{name}"
        # overide referrer id to sweep cache
        define_method(:"#{name}_id=") do |value|
          instance_variable_set(referrer_var, nil)
          super(value)
        end
      end
    end

    module InstanceMethods
      private

      def method_missing(meth, *args, &blk)
        if relationship = self.class.relationships[meth]
          self.class.send(:"lazy_setup_#{relationship.type}", relationship)
          send(meth, *args, &blk)
        else
          super
        end
      end

      def respond_to_missing?(meth, include_private)
        self.class.relationships.has_key?(meth)
      end
    end
  end
end
