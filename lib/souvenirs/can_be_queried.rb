require "souvenirs/query.rb"

module Souvenirs
  module CanBeQueried
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      [:and, :not, :any].each do |op|
        define_method(op) do |options = {}|
          Query.new.send(op, options)
        end
      end
    end

    module InstanceMethods
    end
  end
end
