module Souvenirs
  class Index
    attr_reader :name

    def initialize(name, options = {})
      #options.assert_valid_keys
      @options = options
      @name = name.to_s
    end
  end
end
