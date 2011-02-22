require "souvenirs/key_namer"
require "souvenirs/query.rb"

module Souvenirs
  module CanBeQueried
    extend ActiveSupport::Concern

    module ClassMethods
      [:where, :and, :not, :any].each do |op|
        define_method(op) do |options = {}|
          Query.new(self).send(op, options)
        end
      end

      def sort(*args)
        Query.new(self).send(:sort, *args)
      end

      def all(opts = {})
        result_key = run_expressions(opts.delete(:expressions) || [])
        get_result_ids(result_key, opts).map do |id|
          self[id]
        end
      end

      def paginate(opts = {})
        result_key = run_expressions(opts.delete(:expressions) || [])
        page = opts[:page] || 1
        per_page = opts[:per_page] || 20
        start = (page - 1) * per_page
        opts[:limit] = [start, per_page]
        get_result_ids(result_key, opts).map do |id|
          self[id]
        end
      end

      def first(opts = {})
        result_key = run_expressions(opts.delete(:expressions) || [])
        opts[:limit] = [0, 1]
        ids = get_result_ids(result_key, opts)
        self[ids.first]
      end

      def last(opts = {})
        result_key = run_expressions(opts.delete(:expressions) || [])
        size = redis.scard(result_key)
        opts[:limit] = [size - 1, 1]
        ids = get_result_ids(result_key, opts)
        self[ids.first]
      end

      def rand(opts = {})
        result_key = run_expressions(opts.delete(:expressions) || [])
        size = redis.scard(result_key)
        opts[:limit] = [Kernel.rand(size), 1]
        ids = get_result_ids(result_key, opts)
        self[ids.first]
      end

      private

      def run_expressions(expressions)
        key_all_ids = indices[:all_ids].uidx_key_name
        result_key = expressions.reduce(key_all_ids) do |key, expression|
          type, conditions = expression
          condition_keys = get_keys_for_each_condition(conditions)
          next Array(key) if condition_keys.empty?
          target_key = key_name_for_expression(type, conditions, key)
          send("run_#{type}", target_key, key, condition_keys)
        end
        result_key.empty?? [] : result_key
      end

      def get_keys_for_each_condition(conditions)
        conditions.map do |field, value|
          index = indices[field]
          raise MissingIndex.new(field.to_s) if index.nil?
          index.key_name_for_value(value)
        end
      end

      def key_name_for_expression(type, conditions, previous_key)
        KeyNamer.volatile_set(self, :key => previous_key,
                                    :info => [type] + conditions.keys)
      end

      def get_result_ids(key, opts)
        return redis.smembers(key) unless opts[:sort_by] || opts[:limit]
        sort_key = KeyNamer.sort(self, :sort_by => opts[:sort_by])
        sort_options = opts.slice(:order, :limit)
        redis.sort(key, sort_options.merge(:by => sort_key))
      end

      def run_and(key_name, start_key, keys)
        # we get the intersection of the start key and the condition keys
        redis.sinterstore(key_name, start_key, *keys)
        key_name
      end

      alias :run_where :run_and

      def run_any(key_name, start_key, keys)
        tmp_key = KeyNamer.temporary(self)
        keys.each_with_index do |key, i|
          if i == 0
            # if only one condition key, :any condition is same as :and condition
            redis.sinterstore(key_name, start_key, keys.first)
          else
            # we get the intersection of the start key with each condition key
            # and we make a union of all of those
          end
          redis.sinterstore(tmp_key, start_key, key)
          redis.sunionstore(key_name, key_name, tmp_key)
        end
        redis.del(tmp_key)
        key_name
      end

      def run_not(key_name, start_key, keys)
        keys.each_with_index do |key, i|
          redis.sdiffstore(key_name, i == 0 ? start_key : key_name, key)
        end
        key_name
      end

      def reverse_order(order)
        return order.sub("DESC", "ASC") if order.index("DESC")
        order.sub("ASC", "DESC")
      end
    end
  end
end
