module Souvenirs
  module Model
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::AttributeMethods
      include HasAttributes
      include HasIndices
      include CanBePersisted
      include CanBeQueried
    end
  end

  include Configuration
  include Connection
end
