require "souvenirs/has_attributes"
require "souvenirs/index"

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

      def index(name, options = {})
        instance = Index.new(self, name, options)
        self.indices[name.to_sym] = instance
        instance
      end
    end

    module InstanceMethods
    end
  end
end
