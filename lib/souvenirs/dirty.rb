require "active_model"

module Souvenirs
  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::Dirty

    included do
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
