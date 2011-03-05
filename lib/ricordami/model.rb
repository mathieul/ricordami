module Ricordami
  module Model
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::AttributeMethods
      include IsLockable
      include HasAttributes
      include HasIndices
      include IsPersisted
      include IsRetrievable
    end

    module ClassMethods
      def model_can(*features)
        features.each do |feature|
          require File.expand_path("../can_#{feature}", __FILE__)
          feature_module = Ricordami.const_get(:"Can#{feature.to_s.camelize}")
          include feature_module
        end
      end
    end
  end

  include Configuration
  include Connection
end
