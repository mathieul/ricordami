module Souvenirs
  module HasAttributes
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def attributes
        @attributes ||= {}
      end

      def attribute(name, options = {})
        instance = Attribute.new(name, options)
        self.attributes[instance.name.to_sym] = instance
      end
    end

    module InstanceMethods
    end
  end
end
