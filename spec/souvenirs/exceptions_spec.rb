require "spec_helper"

describe Souvenirs::Error do
  it "has an error to notify when data was not found on the server" do
    Souvenirs::NotFound.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when an attribute is not supported" do
    Souvenirs::AttributeNotSupported.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify an attempty to change a read-only attribute" do
    Souvenirs::ReadOnlyAttribute.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when an index declaration is invalid" do
    Souvenirs::InvalidIndexDefinition.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when a model is deleted" do
    Souvenirs::ModelHasBeenDeleted.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when a type is not supported" do
    Souvenirs::TypeNotSupported.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when an index is missing" do
    Souvenirs::MissingIndex.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when an event is not supported" do
    Souvenirs::EventNotSupported.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when an option value is invalid" do
    Souvenirs::OptionValueInvalid.new.should be_a_kind_of(Souvenirs::Error)
  end
end
