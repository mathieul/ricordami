require "souvenirs/has_attributes"
require "souvenirs/unique_index"
require "souvenirs/simple_index"

module Souvenirs
  module HasIndices
    extend ActiveSupport::Concern

    module ClassMethods
      def indices
        @indices ||= {}
      end

      def index(options = {})
        # for now we can only create unique indices
        options.assert_valid_keys(:unique, :get_by, :simple)
        fields = options.delete(:unique)
        return unique_index(fields, options) if fields.present?
        field = options.delete(:simple)
        return simple_index(field) if field.present?
        raise InvalidIndexDefinition.new(self.class)
      end

      def unique_index(fields, options = {})
        create_unique_index(fields, options).tap do |index|
          next if index.nil?
          create_unique_get_method(index) if options[:get_by]
        end
      end

      def simple_index(field)
        index = SimpleIndex.new(self, field)
        return nil unless add_index(index)
        queue_saving_operations do |obj|
          old_v = obj.send("#{field}_was")
          new_v = obj.send(field)
          next if old_v == new_v
          if obj.persisted? && old_v.present?
            indices[index.name].rem(obj.id, old_v)
          end
          indices[index.name].add(obj.id, new_v)
        end
        queue_deleting_operations do |obj|
          value = obj.send(field)
          indices[index.name].rem(obj.id, value) if value.present?
        end
        index
      end

      private

      def add_index(index)
        return false if self.indices.has_key?(index.name)
        self.indices[index.name] = index
      end

      def create_unique_index(fields, options)
        index = UniqueIndex.new(self, fields, options)
        return nil unless add_index(index)
        queue_saving_operations do |obj|
          old_v = serialize_values(index.fields, obj, :previous => true)
          new_v = serialize_values(index.fields, obj)
          next if old_v == new_v
          if obj.persisted? && old_v.present?
            indices[index.name].rem(obj.id, old_v)
          end
          indices[index.name].add(obj.id, new_v)
        end
        queue_deleting_operations do |obj|
          value = serialize_values(index.fields, obj)
          indices[index.name].rem(obj.id, value) if value.present?
        end
        index
      end

      def create_unique_get_method(index)
        meth = :"get_by_#{index.fields.map(&:to_s).join("-")}"
        define_singleton_method(meth) do |*args|
          all = Souvenirs.driver.hgetall(index.ref_key_name)
          id = index.id_for_values(*args)
          get(id)
        end
      end

      private

      def serialize_values(fields, obj, opts = {})
        fields.map do |f|
          attr = opts[:previous] ? "#{f}_was" : f
          obj.send(attr)
        end.join(UniqueIndex::SEPARATOR)
      end
    end
  end
end
