require "ricordami/has_attributes"
require "ricordami/unique_index"
require "ricordami/value_index"
require "ricordami/order_index"

module Ricordami
  module HasIndices
    extend ActiveSupport::Concern

    module ClassMethods
      def indices
        @indices ||= {}
      end

      def index(options = {})
        options.assert_valid_keys(:unique, :get_by, :value, :scope)
        fields = options.delete(:unique)
        return unique_index(fields, options) if fields.present?
        field = options.delete(:value)
        return value_index(field) if field.present?
        raise InvalidIndexDefinition.new(self.class)
      end

      private

      def add_index(index)
        return false if self.indices.has_key?(index.name)
        self.indices[index.name] = index
      end

      def value_index(field)
        index = ValueIndex.new(self, field)
        return nil unless add_index(index)
        queue_saving_operations do |obj, session|
          old_v = obj.send("#{field}_was")
          new_v = obj.send(field)
          next if old_v == new_v
          if obj.persisted? && old_v.present?
            indices[index.name].rem(obj.id, old_v)
          end
          indices[index.name].add(obj.id, new_v)
        end
        queue_deleting_operations do |obj, session|
          if value = obj.send("#{field}_was")
            indices[index.name].rem(obj.id, value, true).each do |command|
              session.commands << command
            end
          end
        end
        index
      end

      def unique_index(fields, options = {})
        create_unique_index(fields, options).tap do |index|
          next if index.nil?
          create_unique_get_method(index) if options[:get_by]
        end
      end

      def create_unique_index(fields, options)
        index = UniqueIndex.new(self, fields, options)
        return nil unless add_index(index)
        queue_saving_operations do |obj, session|
          old_v = serialize_values(index.fields, obj, :previous => true)
          new_v = serialize_values(index.fields, obj)
          next if old_v == new_v
          if obj.persisted? && old_v.present?
            indices[index.name].rem(obj.id, old_v)
          end
          indices[index.name].add(obj.id, new_v)
        end
        queue_deleting_operations do |obj, session|
          if value = serialize_values(index.fields, obj)
            indices[index.name].rem(obj.id, value, true).each do |command|
              session.commands << command
            end
          end
        end
        index
      end

      def create_unique_get_method(index)
        meth = :"get_by_#{index.fields.map(&:to_s).join("-")}"
        define_singleton_method(meth) do |*args|
          all = redis.hgetall(index.ref_key_name)
          id = index.id_for_values(*args)
          get(id)
        end
      end

      def serialize_values(fields, obj, opts = {})
        fields.map do |f|
          attr = opts[:previous] ? "#{f}_was" : f
          obj.send(attr)
        end.join(UniqueIndex::SEPARATOR)
      end

      def define_singleton_method(*args, &block)
        class << self
          self
        end.send(:define_method, *args, &block)
      end unless method_defined? :define_singleton_method
    end
  end
end
