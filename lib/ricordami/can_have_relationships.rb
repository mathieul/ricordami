require "ricordami/relationship"
require "ricordami/can_be_queried"

module Ricordami
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
          options.merge!(:other => name, :self => self.to_s.underscore.to_sym)
          relationship = Relationship.new(type, options)
          self.relationships[relationship.name] = relationship
          setup_method = :"setup_#{type}"
          send(setup_method, relationship) if respond_to?(setup_method, true)
        end
      end

      private

      def set_block_to_delete_dependents(relationship)
        queue_deleting_operations do |obj, session|
          ref_objs = obj.send(relationship.name)
          ref_objs = [ref_objs] if relationship.type == :references_one
          ref_objs.each { |ref_obj| ref_obj.prepare_delete(session) }
        end
      end

      def set_block_to_nullify_dependents(relationship)
        queue_deleting_operations do |obj, session|
          ref_objs = obj.send(relationship.name)
          ref_objs = [ref_objs] if relationship.type == :references_one
          ref_objs.each do |ref_obj|
            ref_obj.update_attributes(relationship.referrer_id => nil)
          end
        end
      end

      def lazy_setup_references_many(relationship)
        klass = relationship.object_class
        referrer_id_sym = relationship.referrer_id.to_sym
        if relationship.through
          define_method(relationship.name) do |*args|
            options = args.empty?? {} : args.first
            return Query.new([], klass) unless persisted?
            through_ids = self.send(relationship.through).pluck(:"#{relationship.object_kind}_id")
            klass.where(:id => through_ids)
            #klass.get(*through_ids)
          end
        else
          define_method(relationship.name) do
            return Query.new([], klass) unless persisted?
            klass.where(referrer_id_sym => self.id)
          end
          case relationship.dependent
          when :delete  then set_block_to_delete_dependents(relationship)
          when :nullify then set_block_to_nullify_dependents(relationship)
          end
        end
      end

      def define_builders(name, klass, referrer_id_sym)
        # define reference build method
        build_method = :"build_#{name}"
        define_method(build_method) do |*args|
          options = args.first || {}
          klass.new(options.merge(referrer_id_sym => self.id))
        end
        # define reference create method
        define_method(:"create_#{name}") do |*args|
          send(build_method, *args).tap { |obj| obj.save }
        end
      end

      def lazy_setup_references_one(relationship)
        klass = relationship.object_class
        referrer_id_sym = relationship.referrer_id.to_sym
        define_builders(relationship.name, klass, referrer_id_sym)
        # define reference method reader
        define_method(relationship.name) do
          return nil unless persisted?
          klass.where(referrer_id_sym => self.id).first
        end
        case relationship.dependent
        when :delete  then set_block_to_delete_dependents(relationship)
        when :nullify then set_block_to_nullify_dependents(relationship)
        end
      end

      def setup_referenced_in(relationship)
        attribute(relationship.referrer_id, :indexed => :value)
        overide_referrer_id_reader(relationship)
      end

      def lazy_setup_referenced_in(relationship)
        klass = relationship.object_class
        name = relationship.name
        define_builders(name, klass, relationship.referrer_id.to_sym)
        referrer_var = :"@#{name}"
        define_method(name) do
          referrer = instance_variable_get(referrer_var)
          return referrer unless referrer.nil?
          referrer_id_val = send(relationship.referrer_id)
          return nil if referrer_id_val.nil?
          klass.get(referrer_id_val).tap do |referrer|
            instance_variable_set(referrer_var, referrer)
          end
        end
      end

      def overide_referrer_id_reader(relationship)
        referrer_var = :"@#{relationship.name}"
        # overide referrer id to sweep cache
        define_method(:"#{relationship.referrer_id}=") do |value|
          instance_variable_set(referrer_var, nil)
          super(value)
        end
      end
    end

    module InstanceMethods
      private

      RE_METHOD = /^(build|create)_(.*)$/

      def method_missing(meth, *args, &blk)
        match = RE_METHOD.match(meth.to_s)
        meth_root = match.nil?? meth : match[2].to_sym
        if relationship = self.class.relationships[meth_root]
          self.class.send(:"lazy_setup_#{relationship.type}", relationship)
          send(meth, *args, &blk)
        else
          super
        end
      end

      if Object.respond_to?(:respond_to_missing?)
        def respond_to_missing?(meth, include_private)
          self.class.relationships.has_key?(meth)
        end
      else
        def respond_to?(meth)
          match = RE_METHOD.match(meth.to_s)
          meth_root = match.nil?? meth : match[2].to_sym
          return true if self.class.relationships.has_key?(meth_root)
          super
        end
        public :respond_to?
      end
    end
  end
end
