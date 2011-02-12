module Souvenirs
  class Query
    attr_reader :expressions

    def initialize
      @expressions = []
    end

    [:and, :not, :any].each do |op|
      define_method(op) do |options = {}|
        @expressions << [op, options.dup]
        self
      end
    end
  end
end
