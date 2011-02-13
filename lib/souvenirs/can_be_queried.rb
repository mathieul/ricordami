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
          raise TypeNotSupported if type != :and
          run_and_expression(conditions, key)
        end
        return [] if found.empty?
        Souvenirs.driver.smembers(found).map  { |id| self[id] }
      end

      private

      def run_and_expression(conditions, initial_key = nil)
        # get index value key for each condition
        info = [:and]
        keys = conditions.map do |field, value|
          index = indices[field]
          raise MissingIndex.new(field.to_s) if index.nil?
          info << field
          index.key_name_for_value(value)
        end
        keys.unshift(initial_key) unless initial_key.nil?

        # run a difference of all index value key
        key_name = Factory.key_name(:volatile_set,
                                    :model => self,
                                    :key => initial_key,
                                    :info => info)
        Souvenirs.driver.sinterstore(key_name, *keys)
        key_name
      end
    end
  end
end
