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
        expressions.each do |type, conditions|
          raise TypeNotSupported if type != :and
        end
        conditions = expressions.first.last
        run_and_expression(conditions).map { |id| self[id] }
      end

      private

      def run_and_expression(conditions)
        # get index value key for each condition
        keys = conditions.map do |field, value|
          index = indices[field]
          raise MissingIndex.new(field.to_s) if index.nil?
          index.key_name_for_value(value)
        end

        # run a difference of all index value key
        Souvenirs.driver.sinter(*keys)
      end
    end
  end
end
