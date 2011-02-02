module Souvenirs
  module HasAttributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    included do
      attribute_method_suffix('', '=')
    end

    module ClassMethods
      def attributes
        @attributes ||= {}
      end

      def attribute(name, options = {})
        instance = Attribute.new(name, options)
        self.attributes[instance.name.to_sym] = instance
        instance
      end
    end

    module InstanceMethods
      attr_reader :attributes

      def initialize(attrs = {})
        @attributes = {}.with_indifferent_access
        set_default_attribute_values
        overwrite_attribute_values_with(attrs) unless attrs.empty?
      end

      private

      def attribute(name)
        @attributes[name]
      end

      def attribute=(name, value)
        definition = self.class.attributes[name.to_sym]
        current_value = @attributes[name]
        if definition.read_only? && current_value.present?
          raise ReadOnlyAttribute.new("can't change #{name}")
        end
        @attributes[name] = value
      end

      def set_default_attribute_values
        self.class.attributes.each do |name, attribute|
          @attributes[name] = attribute.default_value
        end
      end

      def overwrite_attribute_values_with(attrs)
        valid_keys = self.class.attributes.keys
        attrs.slice(*valid_keys).each do |name, value|
          @attributes[name] = value
        end
      end
    end
  end
end
