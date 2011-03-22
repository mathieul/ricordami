require "spec_helper"

describe Ricordami::Error do
  it "has an error to notify when data was not found on the server" do
    Ricordami::NotFound.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when an attribute is not supported" do
    Ricordami::AttributeNotSupported.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify an attempty to change a read-only attribute" do
    Ricordami::ReadOnlyAttribute.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when an index declaration is invalid" do
    Ricordami::InvalidIndexDefinition.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when a model is deleted" do
    Ricordami::ModelHasBeenDeleted.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when a type is not supported" do
    Ricordami::TypeNotSupported.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when an index is missing" do
    Ricordami::MissingIndex.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when an event is not supported" do
    Ricordami::EventNotSupported.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when an option value is invalid" do
    Ricordami::OptionValueInvalid.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when mandatory arguments are missing" do
    Ricordami::MissingMandatoryArgs.new.should be_a_kind_of(Ricordami::Error)
  end

  it "has an error to notify when an option is invalid in the current context" do
    Ricordami::OptionNotAllowed.new.should be_a_kind_of(Ricordami::Error)
  end
end
