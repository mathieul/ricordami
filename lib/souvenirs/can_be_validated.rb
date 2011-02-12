require "active_model/validations"
require "souvenirs/unique_validator"

module Souvenirs
  module CanBeValidated
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    module ClassMethods
      def validates_uniqueness_of(*attr_names)
        validates_with UniqueValidator, _merge_attributes(attr_names)
      end
    end

    module InstanceMethods
      def valid?
        raise ModelHasBeenDeleted.new("can't validate a deleted model") if deleted?
        super
      end

      def save(opts = {})
        return false unless opts[:validate] == false || valid?
        super(opts)
      end

      def save!(opts = {})
        raise ModelInvalid unless opts[:validate] == false || valid?
        super(opts)
      end
    end
  end
end
