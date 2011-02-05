require "active_model/validations"

module Souvenirs
  module CanBeValidated
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
