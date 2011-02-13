module Souvenirs
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
  end

  include Configuration
  include Connection
end
