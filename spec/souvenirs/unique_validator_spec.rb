require "spec_helper"
require "souvenirs/can_be_validated"

describe Souvenirs::UniqueValidator do
  uses_constants("Call")

  before(:each) do
    class Call
      include Souvenirs::CanBeValidated
      attribute :name
    end
  end
  let(:record) { Call.new(:name => "sophie") }
  let(:validator) { Souvenirs::UniqueValidator.new(:attributes => [:name]) }

  it "is an active model EachValidator" do
    validator.is_a?(ActiveModel::EachValidator)
  end

  it "#setup adds a unique index" do
    validator.setup(Call)
    Call.indices[:name].should be_a(Souvenirs::UniqueIndex)
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
    validator = Souvenirs::UniqueValidator.new(:attributes => [:name], :message => "come on, man!")
    validator.setup(Call)
    record.save
    sophie = Call.new(:name => "sophie")
    validator.validate_each(sophie, :name, record.name)
    sophie.errors[:name].should == ["come on, man!"]
  end
end
