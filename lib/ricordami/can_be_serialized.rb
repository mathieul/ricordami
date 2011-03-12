require "active_model"

module Ricordami
  module CanBeSerialized
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Serializers::JSON
      include ActiveModel::Serializers::Xml
    end
  end
end
