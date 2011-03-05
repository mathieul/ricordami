module Ricordami
  class Query
    attr_reader :expressions, :runner, :builder, :sort_by, :sort_dir

    def initialize(runner, builder = nil)
      @expressions = []
      @runner = runner
      @builder = builder || runner
    end

    [:and, :not, :any].each do |op|
      define_method(op) do |*args|
        options = args.first || {}
        @expressions << [op, options.dup]
        self
      end
    end
    alias :where :and

    [:all, :paginate, :first, :last, :rand].each do |cmd|
      define_method(cmd) do |*args|
        return runner unless runner.respond_to?(cmd)
        options = args.first || {}
        options[:expressions] = expressions
        options[:sort_by] = @sort_by unless @sort_by.nil?
        options[:order] = order_for(@sort_dir) unless @sort_dir.nil?
        runner.send(cmd, options)
      end
    end

    def sort(attribute, dir = :asc_alpha)
      unless [:asc_alpha, :asc_num, :desc_alpha, :desc_num].include?(dir)
        raise ArgumentError.new("sorting direction #{dir.inspect} is invalid")
      end
      @sort_by, @sort_dir = attribute, dir
      self
    end

    def build(attributes = {})
      initial_values = {}
      expressions.each do |operation, filters|
        next unless operation == :and
        initial_values.merge!(filters)
      end
      obj = builder.new(initial_values.merge(attributes))
    end

    def create(attributes = {})
      build(attributes).tap { |obj| obj.save }
    end

    private

    def order_for(dir)
      case dir
      when nil         then nil
      when :asc_alpha  then "ALPHA ASC"
      when :asc_num    then "ASC"
      when :desc_alpha then "ALPHA DESC"
      else                  "DESC"
      end
    end

    def method_missing(meth, *args, &blk)
      all.send(meth, *args, &blk)
    end
  end
end