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
        found = expressions.reduce(nil) do |key, expression|
          type, conditions = expression
          raise TypeNotSupported unless [:and, :or].include?(type)
          if conditions.empty?
            Array(key)
          else
            keys = get_keys_for_each_condition(conditions)
            key_name = key_name_for_expression(type, conditions, key)
            send("run_expression_#{type}", key_name, key, keys)
          end
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

      def key_name_for_expression(type, conditions, initial_key)
        Factory.key_name(:volatile_set,
                         :model => self,
                         :key => initial_key,
                         :info => [type] + conditions.keys)
      end

      def run_expression_and(key_name, start_key, keys)
        keys.unshift(start_key) unless start_key.nil?
        Souvenirs.driver.sinterstore(key_name, *keys)
        key_name
      end

      def run_expression_or(key_name, start_key, keys)
        raise "TODO"
        Souvenirs.driver.sinterstore(key_name, *keys)
        key_name
      end
    end
  end
end
