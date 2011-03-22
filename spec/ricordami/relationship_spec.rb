require "spec_helper"
require "ricordami/relationship"

describe Ricordami::Relationship do
  def valid_options
    {:other => :blih, :self => :blah}
  end
  uses_constants("Stuff")
  subject { Ricordami::Relationship }

  describe "using most options" do
    subject do
      Ricordami::Relationship.new(:references_many, :other => :stuffs,
                                  :as => :things, :self => :person,
                                  :alias => :owner, :dependent => :delete)
    end

    it("has a type") { subject.type.should == :references_many }

    it("has a name") { subject.name.should == :things }

    it("has an object kind") { subject.object_kind.should == :stuff }

    it("returns the object class") { subject.object_class.should == Stuff }

    it("has a self kind") { subject.self_kind.should == :person }

    it("has an alias") { subject.alias.should == :owner }

    it("has a referrer id") { subject.referrer_id.should == "owner_id" }

    it("has a dependent attribute") { subject.dependent.should == :delete }
  end

  describe "other cases" do
    it "can specify an optional dependent option" do
      relationship = subject.new(:references_many, valid_options.merge(:dependent => :delete))
      relationship.dependent.should == :delete
    end

    it "deducts the object kind from the other parameter" do
      relationship = subject.new(:references_many, valid_options.merge(:other => :stuffs))
      relationship.name.should == :stuffs
      relationship.object_kind.should == :stuff
    end

    it "can specify an optional as option that is the relationship name" do
      relationship = subject.new(:references_many, valid_options.merge(:other => :stuffs, :as => :things))
      relationship.name.should == :things
      relationship.object_kind.should == :stuff
    end

    it "deducts the referrer id from the other or as parameter for a referenced_in relationship" do
      relationship = subject.new(:referenced_in, :self => :ingredient, :other => :cook)
      relationship.referrer_id.should == "cook_id"
      relationship = subject.new(:referenced_in, :self => :ingredient, :other => :cook, :as => :chef)
      relationship.referrer_id.should == "chef_id"
    end

    it "deducts the referrer id from the self or alias parameter for a references_many relationship" do
      relationship = subject.new(:references_many, :self => :cook, :other => :ingredients)
      relationship.referrer_id.should == "cook_id"
      relationship = subject.new(:references_many, :self => :cook, :alias => :chef, :other => :ingredients, :as => :stuff)
      relationship.referrer_id.should == "chef_id"
    end

    it "deducts the referrer id from the self or alias parameter for a references_one relationship" do
      relationship = subject.new(:references_one, :self => :cook, :other => :hat)
      relationship.referrer_id.should == "cook_id"
      relationship = subject.new(:references_one, :self => :cook, :alias => :chef, :other => :hat, :as => :toque)
      relationship.referrer_id.should == "chef_id"
    end

    it "can specify an optional alias that is the relationship name for the other party" do
      relationship = subject.new(:references_many, valid_options.merge(:self => :person, :alias => :owners))
      relationship.alias.should == :owners
      relationship.self_kind.should == :person
    end

    it "can request a references_many relationship to be through another one" do
      relationship = subject.new(:references_many, valid_options.merge(:through => :things))
      relationship.through.should == :things
    end
  end

  describe "error cases" do
    it "raises an error if all the mandatory parameters are not present" do
      [{}, {:other => :blah}, {:self => :blih}].each do |options|
        lambda {
          subject.new(:references_many, options)
        }.should raise_error(Ricordami::MissingMandatoryArgs)
      end
    end

    it "doesn't raise an error if all mandatory parameters are present" do
      lambda {
        subject.new(:referenced_in, :other => :blah, :self => :blih)
      }.should_not raise_error
    end

    it "raises an error if the type is not supported" do
      lambda { subject.new(:references_many, valid_options) }.should_not raise_error
      lambda { subject.new(:referenced_in, valid_options) }.should_not raise_error
      lambda { subject.new(:references_one, valid_options) }.should_not raise_error
      lambda {
        subject.new(:blah, valid_options)
      }.should raise_error(Ricordami::TypeNotSupported)
    end

    it "raises an error if dependent is set but not equal to :nullify or :delete" do
      lambda {
        subject.new(:references_many, valid_options.merge(:dependent => :nullify))
      }.should_not raise_error
      lambda {
        subject.new(:references_many, valid_options.merge(:dependent => :delete))
      }.should_not raise_error
      lambda {
        subject.new(:references_many, valid_options.merge(:dependent => :what))
      }.should raise_error(Ricordami::OptionValueInvalid)
    end

    it "raises an error if through is set for a non 'references_many' relationship" do
      lambda {
        subject.new(:references_one, valid_options.merge(:through => :things))
      }.should raise_error(Ricordami::OptionNotAllowed)
      lambda {
        subject.new(:referenced_in, valid_options.merge(:through => :things))
      }.should raise_error(Ricordami::OptionNotAllowed)
      lambda {
        subject.new(:references_many, valid_options.merge(:through => :things))
      }.should_not raise_error
    end

    it "raises an error if an option is not supported" do
      lambda {
        subject.new(:references_many, valid_options.merge(:not_supported => :blah))
      }.should raise_error(ArgumentError)
    end
  end
end
