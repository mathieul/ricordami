require "souvenirs/has_attributes"
require "souvenirs/unique_index"

module Souvenirs
  module HasIndices
    extend ActiveSupport::Concern

    included do
      unless ancestors.include?(HasAttributes)
        raise RuntimeError.new("missing mandatory module Souvenirs::HasAttributes")
      end
    end

    module ClassMethods
      def indices
        @indices ||= {}
      end

      def index(options = {})
        # for now we can only create unique indices
        options.assert_valid_keys(:unique)
        fields = options.delete(:unique)
        raise InvalidIndexDefinition.new(self.class) if fields.blank?
        create_unique_index(fields, options)
      end

      private

      def create_unique_index(fields, options)
        index = UniqueIndex.new(self, fields, options)
        self.indices[index.name.to_sym] = index
        index_name = index.name.to_sym
        queue_saving_operations do |obj|
          old_value = index.package_fields(obj, :previous_value => true)
          new_value = index.package_fields(obj)
          next if old_value == new_value
          if obj.persisted? && old_value.present?
            indices[index_name].rem(old_value)
          end
          indices[index_name].add(new_value)
        end
        queue_deleting_operations do |obj|
          value = index.package_fields(obj, :for_deletion => true)
          indices[index_name].rem(value) if value.present?
        end
        index
      end
    end

    module InstanceMethods
    end
  end
end
