require "spec_helper"

describe Souvenirs::Dirty do
  uses_constants("Plane")
  before(:each) do
    Plane.attribute :parts
    Plane.attribute :model
  end

  describe "a model freshly initialized" do
    before(:each) { @plane = Plane.new }
    let(:plane) { @plane }

    it "was not changed if it's a new record" do
      plane.should_not be_changed
      plane.changed.should be_empty
      plane.changes.should be_empty
    end
  end
end
