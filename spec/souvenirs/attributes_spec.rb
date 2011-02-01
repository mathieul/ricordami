require "spec_helper"

describe Souvenirs::Attributes do
  uses_constants("Boat")

  describe "the class" do
    it "can declare attributes using #attribute" do
      Boat.attribute :sail
      Boat.attributes[:sail].should be_a(Souvenirs::Attribute)
      Boat.attributes[:sail].name.should == "sail"
    end

    it "can pass attribute options when declaring an attribute" do
      Boat.attribute :color, :default => "black", :read_only => true
      Boat.attribute[:color].default_value.should == "black"
      Boat.attribute[:color].read_only.should be_true
    end
  end
end
