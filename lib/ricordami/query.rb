require "ricordami/meta_field.rb"
require "ricordami/condition.rb"

module Ricordami
  class Query
    VALID_DIRECTIONS = [:asc, :desc, :asc_num, :desc_num]

    attr_reader :filters, :runner, :builder, :sort_by, :sort_dir,
                :to_return, :store_result

    def initialize(runner, builder = nil)
      @filters = []
      @runner = runner
      @builder = builder || runner
      @to_return = runner
      @store_result = false
    end

    [:and, :not, :any].each do |op|
      define_method(op) do |*args|
        options = args.first || {}
        filter = options.map { |meta_field, value| Condition.new(meta_field, value) }
        @filters << [op, filter]
        self
      end
    end
    alias :where :and

    [:all, :paginate, :first, :last, :rand].each do |cmd|
      define_method(cmd) do |*args|
        return runner unless runner.respond_to?(cmd)
        options               = args.first || {}
        options[:filters]     = filters
        options[:return]      = @to_return
        options[:store]       = @store_result
        options[:sort_by]     = @sort_by unless @sort_by.nil?
        options[:order]       = order_for(@sort_dir) unless @sort_dir.nil?
        runner.send(cmd, options)
      end
    end

    def sort(opts)
      @sort_by = opts.keys.first
      @sort_dir = opts[@sort_by]
      raise ArgumentError unless VALID_DIRECTIONS.include?(@sort_dir)
      self
    rescue
      raise ArgumentError.new("sorting parameter is invalid: #{opts.inspect}")
    end

    def pluck(field)
      @to_return = field
      self
    end

    def pluck!(field)
      @store_result = true
      pluck(field)
    end

    def build(attributes = {})
      initial_values = {}
      filters.each do |operation, conditions|
        next unless operation == :and
        conditions.each do |condition|
          if condition.operator == :eq
            initial_values[condition.field] = condition.value
          end
        end
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
      when :asc        then "ALPHA ASC"
      when :asc_num    then "ASC"
      when :desc       then "ALPHA DESC"
      else                  "DESC"
      end
    end

    def method_missing(meth, *args, &blk)
      all.send(meth, *args, &blk)
    end
  end
end
