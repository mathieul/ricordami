require "spec_helper"
require "souvenirs/relationship"

describe Souvenirs::Relationship do
    subject { Souvenirs::Relationship }

  describe "an instance" do
    it "has a type and a name" do
      relationship = subject.new(:references_many, :stuffs)
      relationship.type.should == :references_many
      relationship.name.should == :stuffs
    end

    it "raises an error if the type is not supported" do
      lambda { subject.new(:references_many, :name) }.should_not raise_error
      lambda { subject.new(:referenced_in, :name) }.should_not raise_error
      lambda {
        subject.new(:blah, :name)
      }.should raise_error(Souvenirs::TypeNotSupported)
    end

    it "can specify an optional dependent option" do
      relationship = subject.new(:references_many, :stuffs, :dependent => :delete)
      relationship.dependent.should == :delete
    end

    it "raises an error if dependent is set but not equal to :nullify or :delete" do
      lambda {
        subject.new(:references_many, :name, :dependent => :nullify)
      }.should_not raise_error
      lambda {
        subject.new(:references_many, :name, :dependent => :delete)
      }.should_not raise_error
      lambda {
        subject.new(:references_many, :stuffs, :dependent => :what)
      }.should raise_error(Souvenirs::OptionValueInvalid)
    end

    it "raises an error if an option is not supported" do
      lambda {
        subject.new(:references_many, :stuffs, :not_supported => :blah)
      }.should raise_error(ArgumentError)
    end
  end
end
