module Souvenirs
  module CanBePersistent
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
    end

    module InstanceMethods
      def initialize(*args)
        super(*args)
        @persisted = false unless instance_variable_defined?(:@persisted)
      end

      def persisted?
        @persisted
      end

      def save
        @persisted = true
      end
    end
  end
end
