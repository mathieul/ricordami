require "spec_helper"
require "souvenirs/can_be_observed"

describe Souvenirs::CanBeObserved do
  uses_constants("Token")

  before(:each) do
    class Token
      include Souvenirs::CanBeObserved
      attribute :queue
      attribute :skill
    end
  end

  pending
end
