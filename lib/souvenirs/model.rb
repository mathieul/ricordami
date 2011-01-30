module Souvenirs
  module Model
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Naming
    end
  end
end
