require "spec_helper"

describe Souvenirs::Error do
  it "has an error to notify when data was not found on the server" do
    Souvenirs.const_defined?(:"DataNotFound").should be_true
    Souvenirs::NotFound.new.should be_a_kind_of(Souvenirs::Error)
  end

  it "has an error to notify when the model is not valid" do
    Souvenirs.const_defined?(:"ModelInvalid").should be_true
    Souvenirs::ModelInvalid.new.should be_a_kind_of(Souvenirs::Error)
  end
end
