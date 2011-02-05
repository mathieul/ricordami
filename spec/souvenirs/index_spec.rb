require "spec_helper"

describe Souvenirs::Index do
  subject { Souvenirs::Index }

  it "has a name" do
    index = subject.new("singer")
    index.name.should == "singer"
  end

  it "accepts a string for its name" do
    index = subject.new("string")
    index.name.should == "string"
  end

  it "accepts also a symbol for its name" do
    index = subject.new(:string)
    index.name.should == "string"
  end
end
