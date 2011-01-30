require "spec_helper"

describe Souvenirs::Error do
  it "has an error to notify when something was not found" do
    Souvenirs.should have_const_defined(:"NotFound")
  end
end
