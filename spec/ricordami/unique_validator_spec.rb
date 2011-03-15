require "spec_helper"
require "ricordami/can_be_validated"

describe Ricordami::UniqueValidator do
  uses_constants("Call")

  before(:each) do
    Call.send(:include, Ricordami::CanBeValidated)
    Call.attribute :name
  end
  let(:record) { Call.new(:name => "sophie") }
  let(:validator) { Ricordami::UniqueValidator.new(:attributes => [:name]) }

  it "is an active model EachValidator" do
    validator.is_a?(ActiveModel::EachValidator)
  end

  it "#setup adds a unique index" do
    validator.setup(Call)
    Call.indices[:u_name].should be_a(Ricordami::UniqueIndex)
  end

  it "#validate_each adds an error if the value is already used" do
    validator.setup(Call)
    record.save

    sophie = Call.new(:name => "sophie")
    validator.validate_each(sophie, :name, record.name)
    sophie.should have(1).error
    sophie.errors[:name].should == ["is already used"]
  end

  it "accepts an option :message to change the error message" do
    validator = Ricordami::UniqueValidator.new(:attributes => [:name], :message => "come on, man!")
    validator.setup(Call)
    record.save
    sophie = Call.new(:name => "sophie")
    validator.validate_each(sophie, :name, record.name)
    sophie.errors[:name].should == ["come on, man!"]
  end

  it "accepts a scope option to limit the unicity constraint" do
    Call.attribute :family
    validator = Ricordami::UniqueValidator.new(:attributes => [:name], :scope => :family)
    validator.setup(Call)
    Call.create(:name => "john", :family => "jones")
    john = Call.new(:name => "john", :family => "jones")
    validator.validate_each(john, :name, john.name)
    john.should have(1).error
    john.family = "doe"
    john.errors.clear
    validator.validate_each(john, :name, john.name)
    john.should have(0).errors
  end
end
