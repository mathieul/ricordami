module Souvenirs
  class Query
    attr_reader :expressions, :runner, :sort_by, :sort_dir

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
        sort_info = @sort_by.nil?? nil : [@sort_by, @sort_dir]
        runner.send(cmd, expressions, sort_info)
      end
    end

    def sort(attribute, dir = :asc)
      unless dir == :asc || dir == :desc
        raise ArgumentError.new("sorting direction #{dir.inspect} is invalid")
      end
      @sort_by, @sort_dir = attribute, dir
      self
    end
  end
end
