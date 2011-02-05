require "spec_helper"

describe Souvenirs::HasIndices do
  it "requires the module Souvenirs::HasHasIndices" do
    lambda {
      WillFail = Class.new do
        include Souvenirs::HasIndices
      end
    }.should raise_error(RuntimeError)
  end

  describe "the class" do
    uses_constants("Car")

    it "can declare indices with #index" do
      Car.attribute :model
      index = Car.index :model
      Car.indices[:model].should be_a(Souvenirs::Index)
      Car.indices[:model].should == index
    end
  end
end
