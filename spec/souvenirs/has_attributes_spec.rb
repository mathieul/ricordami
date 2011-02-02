require "spec_helper"

describe Souvenirs::HasAttributes do
  uses_constants("Boat", "Song", "User")

  describe "the class" do
    it "can declare attributes using #attribute" do
      Boat.attribute :sail
      Boat.attributes[:sail].should be_a(Souvenirs::Attribute)
      Boat.attributes[:sail].name.should == "sail"
    end

    it "can pass attribute options when declaring an attribute" do
      Boat.attribute :color, :default => "black", :read_only => true
      Boat.attributes[:color].default_value.should == "black"
      Boat.attributes[:color].should be_read_only
    end
  end

  describe "an instance" do
    it "can be initialized with a hash of attribute values" do
      User.attribute :name
      User.attribute :age, :default => "18"
      User.attribute :ssn, :read_only => true
      user = User.new(:name => "jean", :age => "20", :ssn => "1234567890")
      user.name.should == "jean"
      user.age.should == "20"
      user.ssn.should == "1234567890"
    end

    it "can set attributes using writers" do
      User.attribute :email
      user = User.new
      user.email.should be_nil
      user.email = "blah@toto.com"
      user.email.should == "blah@toto.com"
    end
  end
end
