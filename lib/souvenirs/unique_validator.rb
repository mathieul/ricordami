module Souvenirs
  class UniqueValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      index_name = "all_#{attribute}s".to_sym
      index = record.class.indices[index_name]
      if index.include?(value)
        record.errors.add(attribute, "is already used")
      end
    end

    def setup(klass)
      attributes.each { |attribute| klass.index :unique => attribute }
    end
  end
end
