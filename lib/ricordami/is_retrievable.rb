require "ricordami/is_persisted"
require "ricordami/has_indices"

module Ricordami
  module IsRetrievable
    extend ActiveSupport::Concern

    included do
      index :unique => :id
    end

    module ClassMethods
      def get(id)
        attributes = load_attributes_for(id)
        raise NotFound.new("id = #{id}") if attributes.empty?
        new(attributes).tap do |instance|
          instance.instance_eval do
            @persisted = true
            attributes_synced_with_db!
          end
        end
      end
      alias :[] :get

      def all(expressions = nil)
        ids = indices[:u_id].all
        ids.map { |id| get(id) }
      end

      def count
        indices[:u_id].count
      end
    end
  end
end
