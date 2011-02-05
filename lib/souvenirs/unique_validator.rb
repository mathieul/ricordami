module Souvenirs
  class UniqueValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      puts "validate_each(record, #{attribute.inspect}, #{value.inspect})"
      index_name = "all_#{attribute}s".to_sym
      index = record.class.indices[index_name]
      if index.include?(value)
        puts "YES => #{attribute.inspect}"
        record.errors.add(attribute, "is already used")
      end
    end

    def setup(klass)
      puts "setup"
      attributes.each { |attribute| klass.index :unique => attribute }
    end
  end
end
