module Souvenirs
  class Query
    attr_reader :expressions, :runner

    def initialize(runner)
      @expressions = []
      @runner = runner
    end

    [:and, :not, :any].each do |op|
      define_method(op) do |options = {}|
        @expressions << [op, options.dup]
        self
      end
    end
    alias :where :and

    [:all, :first, :last].each do |cmd|
      define_method(cmd) do
        runner.send(cmd, expressions)
      end
    end
  end
end
