require "souvenirs/index"

module Souvenirs
  module HasIndices
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def indices
        @indices ||= {}
      end

      def index(name, options = {})
      end
    end

    module InstanceMethods
    end
  end
end
