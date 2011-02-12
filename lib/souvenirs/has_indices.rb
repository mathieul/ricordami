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
          old_value = index.package_fields(obj, :previous_value => true)
          new_value = index.package_fields(obj)
          next if old_value == new_value
          if obj.persisted? && old_value.present?
            indices[index.name].rem(obj.id, old_value)
          end
          indices[index.name].add(obj.id, new_value)
        end
        queue_deleting_operations do |obj|
          value = index.package_fields(obj, :for_deletion => true)
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
    end
  end
end
