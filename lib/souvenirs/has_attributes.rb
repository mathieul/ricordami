require "souvenirs/attribute"

module Souvenirs
  module HasAttributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty

    included do
      attribute_method_suffix('', '=')
      attribute :id, :read_only => true,
                     :default   => Proc.new { SimpleUUID::UUID.new.to_guid }
    end

    module ClassMethods
      def attributes
        @attributes ||= {}
      end

      def attribute(name, options = {})
        instance = Attribute.new(name, options)
        self.attributes[name.to_sym] = instance
        instance
      end

      def attributes_key_name_for(id)
        "#{self.to_s.underscore}:#{id}:attributes"
      end
    end

    module InstanceMethods
      attr_reader :attributes

      def initialize(attrs = {})
        @attributes = {}.with_indifferent_access
        load_mem_attributes(attrs) unless attrs.empty?
        set_default_attribute_values
      end

      # Replace attribute values with the hash attrs
      # Note: attrs keys can be strings or symbols
      def update_mem_attributes!(attrs)
        valid_keys = self.class.attributes.keys
        attrs.symbolize_keys.slice(*valid_keys).each do |name, value|
          assert_can_update!(name)
          write_attribute(name, value)
        end
        true
      end

      def load_mem_attributes(attrs)
        valid_keys = self.class.attributes.keys
        attrs.symbolize_keys.slice(*valid_keys).each do |name, value|
          write_attribute(name, value)
        end
        true
      end

      private

      def write_attribute(name, value)
        return value if @attributes[name] == value
        if @persisted_attributes && @persisted_attributes[name] == value
          @changed_attributes.delete(name.to_s)
        else
          attribute_will_change!(name.to_s)
        end
        @attributes[name] = value
      end

      def attribute(name)
        @attributes[name]
      end

      def attribute=(name, value)
        assert_can_update!(name)
        write_attribute(name, value)
      end

      def assert_can_update!(name)
        definition = self.class.attributes[name.to_sym]
        if definition.read_only? && @attributes[name].present?
          raise ReadOnlyAttribute.new("can't change #{name}")
        end
      end

      def set_default_attribute_values
        self.class.attributes.each do |name, attribute|
          @attributes[name] = attribute.default_value unless @attributes.has_key?(name)
        end
      end

      def attributes_key_name
        @attributes_key_name ||= self.class.attributes_key_name_for(id)
      end

      def attributes_synced_with_db!
        @persisted_attributes = @attributes.clone
        @previously_changed = changes
        @changed_attributes.clear if @changed_attributes
      end
    end
  end
end
