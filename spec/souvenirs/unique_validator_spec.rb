require "spec_helper"

describe Souvenirs::UniqueValidator do
  subject { Souvenirs::UniqueValidator }

  uses_constants("Call")

  before(:each) do
    Call.attribute :name
    @record = Call.new(:name => "sophie")
    @validator = subject.new(:attributes => [:name])
  end

  it "is an active model EachValidator" do
    @validator.is_a?(ActiveModel::EachValidator)
  end

  it "#setup adds a unique index" do
    @validator.setup(Call)
    Call.indices[:all_names].should be_a(Souvenirs::UniqueIndex)
  end

  it "#validate_each adds an error if the value is already used" do
    @validator.setup(Call)
    @record.save!

    sophie = Call.new(:name => "sophie")
    @validator.validate_each(sophie, :name, sophie.name)
    sophie.should have(1).error
    sophie.errors[:name].should == ["is already used"]
  end
end
