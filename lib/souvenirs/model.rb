module Souvenirs
  module Model
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include HasAttributes
    end
  end

  include Configuration
  include Connection
end
