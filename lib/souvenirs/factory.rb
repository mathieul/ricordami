module Souvenirs
  module Factory
    extend self

    def id_generator(type)
      meth = "#{type}_proc".to_sym
      raise TypeNotSupported.new(type) unless private_method_defined?(meth)
      instance_method(meth).bind(self)
    end

    def key_name(type, opts = {})
      case type
      when :sequence
        "global:seq:#{opts[:name]}"
      when :attributes
        "#{opts[:model]}:attributes:#{opts[:id]}"
      when :unique_index
        "#{opts[:model]}:uidx:#{opts[:name]}"
      end
    end

    private

    def uuid_proc
      SimpleUUID::UUID.new.to_guid
    end

    def sequence_proc
      Souvenirs.driver.incr(key_name(:sequence, :name => "id_generator"))
    end
  end
end
