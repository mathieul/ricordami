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

    it "can be instantiated from a meta field and a value" do
      meta_field = Ricordami::MetaField.new(:size, :lt)
      c = Ricordami::Condition.new(meta_field, 42)
      [c.field, c.operator, c.value].should == [:size, :lt, 42]
    end

    it "can be instantiated from a field, an operator and a value" do
      c = Ricordami::Condition.new(:age, :gte, 12)
      [c.field, c.operator, c.value].should == [:age, :gte, 12]
    end

    it "can be compared to another instance using ==" do
      c1 = Ricordami::Condition.new(:age, :gte, 42)
      c2 = Ricordami::Condition.new(:age, :gte, 42)
      c1.should == c2
    end
  end
end
