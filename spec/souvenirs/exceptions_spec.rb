require "spec_helper"

describe Souvenirs::Error do
  it "has an error to notify when data was not found on the server" do
    Souvenirs::NotFound.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when the model is not valid" do
    Souvenirs::ModelInvalid.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when an attribute is not supported" do
    Souvenirs::AttributeNotSupported.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify an attempty to change a read-only attribute" do
    Souvenirs::ReadOnlyAttribute.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when it couldn't save something to Redis" do
    Souvenirs::WriteToDbFailed.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when an index declaration is invalid" do
    Souvenirs::InvalidIndexDefinition.new.should be_a_kind_of(Souvenirs::Error)
  end
end
