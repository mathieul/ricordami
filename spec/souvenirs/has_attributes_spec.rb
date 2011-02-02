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
      User.attribute :age
      User.attribute :ssn
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

    it "sets default values when initializing without argument" do
      User.attribute :age, :default => "18"
      User.new.age.should == "18"
    end

    it "overwrites default values with arguments when initializing" do
      User.attribute :age, :default => "18"
      User.new(:age => "12").age.should == "12"
    end

    it "can't change a read-only attribute that was initialized" do
      User.attribute :name
      User.attribute :ssn, :read_only => true
      user = User.new(:name => "James Bond", :ssn => "007")
      lambda {
        user.ssn = "1234567890"
      }.should raise_error(Souvenirs::ReadOnlyAttribute)
      lambda {
        user.name = "Titi"
      }.should_not raise_error(Souvenirs::ReadOnlyAttribute)
    end

    it "can set a read-only attribute only once if it was not initialized" do
      User.attribute :name
      User.attribute :ssn, :read_only => true
      user = User.new
      lambda {
        user.ssn = "1234567890"
        user.name = "Titi"
        user.name = "Bob Loblaw"
      }.should_not raise_error(Souvenirs::ReadOnlyAttribute)
      lambda {
        user.ssn = "0987654321"
      }.should raise_error(Souvenirs::ReadOnlyAttribute)
    end
  end
end
