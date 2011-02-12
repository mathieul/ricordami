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
      end
    end
  end
end
