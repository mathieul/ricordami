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
        options.assert_valid_keys(:unique)
        fields = options.delete(:unique)
        raise InvalidIndexDefinition.new(self.class) if fields.blank?
        unique_index = UniqueIndex.new(self, fields, options)
        self.indices[unique_index.name.to_sym] = unique_index
        index_name = unique_index.name.to_sym
        queue_saving_operations do |obj|
          old_value = unique_index.package_fields(obj, :previous_value => true)
          new_value = unique_index.package_fields(obj)
          next if old_value == new_value
          if obj.persisted? && old_value.present?
            indices[index_name].del(old_value)
          end
          indices[index_name].add(new_value)
        end
        unique_index
      end
    end

    module InstanceMethods
    end
  end
end
