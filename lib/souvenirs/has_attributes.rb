require "souvenirs/attribute"

module Souvenirs
  module HasAttributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty

    included do
      attribute_method_suffix('', '=')
      generator = Factory.id_generator(Souvenirs.configuration.id_type || :sequence)
      attribute :id, :read_only => true,
                     :initial   => generator
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

      # ActiveModel::AttributeMethods doesn't seem
      # to generate a reader for id that uses
      # #attributes["id"] in Ruby 1.8.7, so hard-coding
      # it now
      def id
        @attributes["id"]
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
        raise ModelHasBeenDeleted.new("can't update attribute #{name}") if deleted?
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
          unless @attributes.has_key?(name)
            @attributes[name] = if attribute.default_value?
              attribute_will_change!(name.to_s)
              attribute.default_value
            else
              nil
            end
          end
        end
      end

      def set_initial_attribute_values
        self.class.attributes.each do |name, attribute|
          unless @attributes[name].present?
            @attributes[name] = if attribute.initial_value?
              attribute_will_change!(name.to_s)
              attribute.initial_value
            else
              nil
            end
          end
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

=begin
class Zlaj
  include Souvenirs::Model
  attribute :name
end
=end
