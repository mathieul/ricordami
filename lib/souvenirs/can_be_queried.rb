require "souvenirs/query.rb"

module Souvenirs
  module CanBeQueried
    extend ActiveSupport::Concern

    module ClassMethods
      [:and, :not, :any].each do |op|
        define_method(op) do |options = {}|
          Query.new(self).send(op, options)
        end
      end

      def all(expressions = nil)
        return super if expressions.nil?
        key_all_ids = indices[:all_ids].uidx_key_name
        found = expressions.reduce(key_all_ids) do |key, expression|
          type, conditions = expression
          keys = get_keys_for_each_condition(conditions)
          next Array(key) if keys.empty?
          key_name = key_name_for_expression(type, conditions, key)
          send("run_#{type}", key_name, key, keys)
        end
        return [] if found.empty?
        Souvenirs.driver.smembers(found).map  { |id| self[id] }
      end

      private

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

      def run_and(key_name, start_key, keys)
        keys.unshift(start_key)
        Souvenirs.driver.sinterstore(key_name, *keys)
        key_name
      end

      def run_any(key_name, start_key, keys)
        unless start_key.nil?
          Souvenirs.driver.sinterstore(key_name, start_key, keys.shift)
          keys.unshift(key_name)
        end
        Souvenirs.driver.sunionstore(key_name, *keys)
        key_name
      end

      def run_not(key_name, start_key, keys)
        unless start_key.nil?
          Souvenirs.driver.sinterstore(key_name, start_key, keys.shift)
          keys.unshift(key_name)
        end
        Souvenirs.driver.sdiffstore(key_name, *keys)
        key_name
      end
    end
  end
end
