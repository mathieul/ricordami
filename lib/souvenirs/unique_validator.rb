module Souvenirs
  class UniqueValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      index_name = "all_#{attribute}s".to_sym
      puts "name = #{index_name.inspect}"
      index = record.class.indices[index_name]
      puts "index.all = #{index.all.inspect}"
      if index.include?(value)
        record.errors.add(attribute, "is already used")
      end
    end

    def setup(klass)
      attributes.each { |attribute| klass.index :unique => attribute }
    end
  end
end
