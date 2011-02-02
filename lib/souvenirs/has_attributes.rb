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
        puts "added #{instance.name.inspect} - #{self.attributes.inspect}"
        instance
      end

      def defaulted_attributes
        self.attributes.values.select { |value| value.default_value.present? }
      end
    end

    module InstanceMethods
      attr_reader :attributes

      def initialize(attrs = {})
        @attributes = {}.with_indifferent_access
        puts "self.class.attributes: #{self.class.attributes}"
        # set default values
        puts "defaulted_attributes: #{self.class.defaulted_attributes.inspect}"
        self.class.defaulted_attributes.each do |an_attr|
          @attributes[an_attr.name] = an_attr.default_value
        end
        # overwrite with values passed
        attrs.slice(self.class.attributes.keys).each do |name, value|
          @attributes[name] = value
        end
      end

      private

      def attribute(name)
        puts ">>> attribute(#{name})"
        @attributes[name]
      end

      def attribute=(name, value)
        puts ">>> attribute=(#{name}, #{value})"
        @attributes[name] = value
      end
    end
  end
end
