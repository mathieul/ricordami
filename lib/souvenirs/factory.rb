module Souvenirs
  module Factory
    extend self

    ID_SEQ_KEY = "global:seq:id_generator"

    def id_generator(type)
      meth = "#{type}_proc".to_sym
      raise TypeNotSupported.new(type) unless private_method_defined?(meth)
      instance_method(meth).bind(self)
    end

    private

    def uuid_proc
      SimpleUUID::UUID.new.to_guid
    end

    def sequence_proc
      Souvenirs.driver.incr(ID_SEQ_KEY)
    end
  end
end
