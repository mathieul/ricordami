module Souvenirs
  class UniqueValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      index_name = "all_#{attribute}s".to_sym
      index = record.class.indices[index_name]
      if index.include?(value)
        attr_def = record.class.attributes[attribute]
        unless record.persisted? && attr_def.read_only?
          record.errors.add(attribute, "is already used")
        end
      end
    end

    def setup(klass)
      attributes.each { |attribute| klass.index :unique => attribute }
    end
  end
end
