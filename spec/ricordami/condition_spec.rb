require 'spec_helper'
require 'ricordami/condition'

describe Ricordami::Condition do
  describe "a new instance" do
    subject do
      meta_field = Ricordami::MetaField.new(:size, :lt)
      Ricordami::Condition.new(meta_field, 42)
    end

    it "has a field" do
      subject.field.should == :size
    end

    it "has an operator" do
      subject.operator.should == :lt
    end

    it "has a value" do
      subject.value.should == 42
    end
  end
end
