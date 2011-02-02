require "spec_helper"

describe Souvenirs::Attribute do
  subject { Souvenirs::Attribute }

  it "has a name" do
    attribute = subject.new("singer")
    attribute.name.should == "singer"
  end

  it "accepts a string for its name" do
    attribute = subject.new("string")
    attribute.name.should == "string"
  end

  it "accepts also a symbol for its name" do
    attribute = subject.new(:string)
    attribute.name.should == "string"
  end

  it "has an option :default for a default value" do
    attribute = subject.new(:georges, :default => "jungle")
    attribute.default_value.should == "jungle"
  end

  it "doesn't have a default value if :default is not specified" do
    subject.new(:no_defaults).default_value.should be_nil
  end

  it "allows to use a block as a default value for dynamic values" do
    i = 0
    attribute = subject.new(:sequence, :default => Proc.new { i += 1 })
    attribute.default_value.should == 1
    attribute.default_value.should == 2
    attribute.default_value.should == 3
  end

  it "has an option :read_only when the attribute value can only be set once" do
    attribute = subject.new(:georges, :read_only => true)
    attribute.should be_read_only
  end

  it "its value can be set more than once when :read_only is not set" do
    subject.new(:not_read_only).should_not be_read_only
  end
end
