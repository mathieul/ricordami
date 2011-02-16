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

      def all(opts = nil)
        return super if opts.nil?
        result_key = run_expressions(opts.delete(:expressions))
        get_result_ids(result_key, opts).map do |id|
          self[id]
        end
      end

      def first(opts)
        result_key = run_expressions(opts.delete(:expressions))
        opts[:limit] = 1
        id = get_result_ids(result_key, opts).first
        self[id]
      end

      def last(opts)
        result_key = run_expressions(opts.delete(:expressions))
        opts[:limit] = 1
        opts[:order] = reverse_order(opts[:order])
        id = get_result_ids(result_key, opts).first
        self[id]
      end

      def rand(opts)
        result_key = run_expressions(opts.delete(:expressions))
        size = Souvenirs.driver.scard(result_key)
        opts[:start] = Kernel.rand(size)
        opts[:limit] = 1
        opts[:order] = reverse_order(opts[:order])
        id = get_result_ids(result_key, opts).first
        self[id]
      end

      private

      def run_expressions(expressions)
        key_all_ids = indices[:all_ids].uidx_key_name
        result_key = expressions.reduce(key_all_ids) do |key, expression|
          type, conditions = expression
          keys = get_keys_for_each_condition(conditions)
          next Array(key) if keys.empty?
          key_name = key_name_for_expression(type, conditions, key)
          send("run_#{type}", key_name, key, keys)
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
        Factory.key_name(:volatile_set,
                         :model => self,
                         :key => previous_key,
                         :info => [type] + conditions.keys)
      end

      def get_result_ids(key, opts)
        return Souvenirs.driver.smembers(key) if opts[:sort_by].nil?
        sort_key = Factory.key_name(:model_sort,
                                    :model => self,
                                    :sort_by => opts[:sort_by])
        Souvenirs.driver.sort(key,
                              :order => opts[:order],
                              :by => sort_key)
      end

      def run_and(key_name, start_key, keys)
        # we get the intersection of the start key and the condition keys
        Souvenirs.driver.sinterstore(key_name, start_key, *keys)
        key_name
      end

      alias :run_where :run_and

      def run_any(key_name, start_key, keys)
        tmp_key = Factory.key_name(:model_tmp, :model => self)
        keys.each_with_index do |key, i|
          if i == 0
            # if only one condition key, :any condition is same as :and condition
            Souvenirs.driver.sinterstore(key_name, start_key, keys.first)
          else
            # we get the intersection of the start key with each condition key
            # and we make a union of all of those
          end
          Souvenirs.driver.sinterstore(tmp_key, start_key, key)
          Souvenirs.driver.sunionstore(key_name, key_name, tmp_key)
        end
        Souvenirs.driver.del(tmp_key)
        key_name
      end

      def run_not(key_name, start_key, keys)
        keys.each_with_index do |key, i|
          Souvenirs.driver.sdiffstore(key_name, i == 0 ? start_key : key_name, key)
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
