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

    it "returns attributes with default values with #defaulted_attributes" do
      lyrics = Song.attribute :lyrics
      year = Song.attribute :year, :default => "2011"
      singer = Song.attribute :singer, :default => "Serge Gainsbourg"
      Song.defaulted_attributes.should =~ [year, singer]
    end
  end

  describe "an instance" do
    before(:all) do
      User.attribute :name
      User.attribute :age, :default => "18"
      User.attribute :ssn, :read_only => true
      puts "User.attributes => #{User.attributes.inspect}"
    end

    it "can be initialized with a hash of attribute values" do
      user = User.new(:name => "jean", :age => "20", :ssn => "1234567890")
      puts "user.class = #{user.class}"
      puts "user.class.attributes => #{user.class.attributes.inspect}"
      #user.name.should == "jean"
      #user.age.should == "20"
      #user.ssn.should == "1234567890"
    end
  end
end
