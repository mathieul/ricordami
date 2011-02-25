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

    [:all, :paginate, :first, :last, :rand].each do |cmd|
      define_method(cmd) do |options = {}|
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
