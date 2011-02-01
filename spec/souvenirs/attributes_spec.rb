require "spec_helper"

describe Souvenirs::Attributes do
  uses_constants("Boat", "User")

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

  describe "an instance" do
    before(:all) do
      User.attribute :name
      User.attribute :age, :default => "18"
      User.attribute :ssn, :read_only => true
    end

    it "can be initialized with a hash of attribute values" do
      user = User.new(:name => "jean", :age => "20", :ssn => "1234567890")
      user.name.should == "jean"
      user.age.should == "20"
      user.ssn.should == "1234567890"
    end
  end
end
