require "spec_helper"
require "souvenirs/relationship"

describe Souvenirs::Relationship do
  uses_constants("Stuff")
  subject { Souvenirs::Relationship }

  describe "using most options" do
    subject do
      Souvenirs::Relationship.new(:references_many, :other =>:stuffs,
                                  :as => :things, :self => :person,
                                  :alias => :owner, :dependent => true)
    end

    it { subject.type.should == :references_many }

    it { subject.name.should == :stuffs }

    it { subject.object_kind.should == :stuff }

    it { subject.object_class.should == Stuff }

    it { subject.referrer_id.should == "owner_id" }

    it { subject.dependent.should == :delete }
  end

  describe "other cases" do
    pending
    it "can specify an optional dependent option" do
      relationship = subject.new(:references_many, :stuffs, :dependent => :delete)
      relationship.dependent.should == :delete
    end

    it "can specify an optional as option" do
      relationship = subject.new(:references_many, :stuffs, :as => :things)
      relationship.name.should == :things
      relationship.object_kind.should == :stuff
    end
  end

  describe "error cases" do
    pending
    it "raises an error if the type is not supported" do
      lambda { subject.new(:references_many, :name) }.should_not raise_error
      lambda { subject.new(:referenced_in, :name) }.should_not raise_error
      lambda {
        subject.new(:blah, :name)
      }.should raise_error(Souvenirs::TypeNotSupported)
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
