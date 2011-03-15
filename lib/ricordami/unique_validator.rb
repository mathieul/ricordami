require "active_model/validator"

module Ricordami
  class UniqueValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return true unless record.new_record? || record.send(:attribute_changed?, attribute)
      index_name = "u_#{attribute}".to_sym
      index = record.class.indices[index_name]
      if index.scope
        scope_values = index.scope.map { |field| record.send(field) }
        value = index.normalize_value([value].push(*scope_values))
      end
      if index.include?(value)
        attr_def = record.class.attributes[attribute]
        unless record.persisted? && attr_def.read_only?
          record.errors.add(attribute, options[:message] || "is already used")
        end
      end
    end

    def setup(klass)
      attributes.each { |attribute| klass.index :unique => attribute, :scope => options[:scope] }
    end
  end
end
