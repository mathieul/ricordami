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
        instance = UniqueIndex.new(self, fields, options)
        self.indices[instance.name.to_sym] = instance
        instance
      end
    end

    module InstanceMethods
    end
  end
end
