require "ricordami/key_namer"
require "ricordami/query.rb"

module Ricordami
  module CanBeQueried
    extend ActiveSupport::Concern

    module ClassMethods
      [:where, :and, :not, :any].each do |op|
        define_method(op) do |*args|
          options = args.first || {}
          Query.new(self).send(op, options)
        end
      end

      [:sort, :pluck, :pluck!].each do |op|
        define_method(op) do |*args|
          Query.new(self).send(op, *args)
        end
      end

      def all(opts = {})
        result_key = run_filters(opts.delete(:filters) || [])
        ids = get_result_ids(result_key, opts)
        build_result(ids, opts)
      end

      def paginate(opts = {})
        result_key = run_filters(opts.delete(:filters) || [])
        page = opts[:page] || 1
        per_page = opts[:per_page] || 20
        start = (page - 1) * per_page
        opts[:limit] = [start, per_page]
        ids = get_result_ids(result_key, opts)
        build_result(ids, opts)
      end

      def first(opts = {})
        result_key = run_filters(opts.delete(:filters) || [])
        opts[:limit] = [0, 1]
        ids = get_result_ids(result_key, opts)
        build_result(ids, opts).first
      end

      def last(opts = {})
        result_key = run_filters(opts.delete(:filters) || [])
        size = redis.scard(result_key)
        opts[:limit] = [size - 1, 1]
        ids = get_result_ids(result_key, opts)
        build_result(ids, opts).first
      end

      def rand(opts = {})
        result_key = run_filters(opts.delete(:filters) || [])
        size = redis.scard(result_key)
        opts[:limit] = [Kernel.rand(size), 1]
        ids = get_result_ids(result_key, opts)
        build_result(ids, opts).first
      end

      private

      def run_filters(filters)
        key_all_ids = indices[:u_id].uidx_key_name
        result_key = filters.reduce(key_all_ids) do |key, filter|
          type, conditions = filter
          condition_keys = get_keys_for_each_condition(conditions)
          next key if condition_keys.empty?
          target_key = key_name_for_filter(type, conditions, key)
          send("run_#{type}", target_key, key, condition_keys)
        end
        result_key.empty?? [] : result_key
      end

      def get_keys_for_each_condition(conditions)
        conditions.map do |field, value|
          if field == :id
            key_for_id_equality(field, value)
          else
            key_for_value_equality(field, value)
          end
        end
      end

      def key_for_id_equality(field, value)
        ids_key = KeyNamer.temporary(self)
        [value].flatten.each { |v| redis.sadd(ids_key, v) }
        redis.expire(ids_key, 60)
        ids_key
      end

      def key_for_value_equality(field, value)
        index_name = "v_#{field}".to_sym
        index = indices[index_name]
        if index.nil?
          raise MissingIndex.new("Missing value index for #{self}, attribute: '#{index_name}'")
        end
        if value.is_a?(Array)
          value.map { |v| index.key_name_for_value(v) }
        else
          index.key_name_for_value(value)
        end
      end

      def key_name_for_filter(type, conditions, previous_key)
        KeyNamer.volatile_set(self, :key => previous_key,
                                    :info => [type] + conditions.keys)
      end

      def get_result_ids(key, opts)
        store_ids = opts[:store] || (opts[:return] != :id && opts[:return].is_a?(Symbol))
        return redis.smembers(key) unless opts[:sort_by] || opts[:limit] || store_ids
        sort_options = opts.slice(:order, :limit)
        if opts[:sort_by]
          sort_key = KeyNamer.sort(self, :sort_by => opts[:sort_by])
          sort_options.merge!(:by => sort_key)
        end
        if store_ids
          store_key = KeyNamer.temporary(self)
          redis.sort(key, sort_options.merge(:store => store_key))
          redis.expire(store_key, 60)
          store_key
        else
          redis.sort(key, sort_options)
        end
      end

      def build_result(ids, opts)
        result_key = KeyNamer.temporary(self) if opts[:store]
        case opts[:return]
        when :id then
          ids
        when Symbol
          key = KeyNamer.attributes(self.to_s, :id => "*")
          field_name = opts[:return]
          sort_options = {:by => "nosort", :get => "#{key}->#{field_name}"}
          sort_options.merge!(:store => result_key) if result_key
          result = redis.sort(ids, sort_options)
          result_key || result
        else
          ids.map { |id| self[id] }
        end
      end

      def run_and(key_name, start_key, keys)
        # we partition the keys: anys with all OR conditions, alls with all AND conditions
        anys, alls = keys.partition { |key| key.is_a?(Array) }
        unless anys.empty?
          # there are OR conditions, let's add all their content and store it in key_name
          redis.sunionstore(key_name, *anys.flatten)
          alls.unshift(key_name)
        end
        # we get the intersection of the start key and the AND condition keys
        redis.sinterstore(key_name, start_key, *alls)
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
