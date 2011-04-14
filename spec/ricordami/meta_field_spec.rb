require "spec_helper"
require "ricordami/meta_field"

describe Ricordami::MetaField do
  describe "a new instance" do
    subject { Ricordami::MetaField.new(:size, :gte) }

    it "has a name" do
      subject.name.should == :size
    end

    it "has an operator" do
      subject.operator.should == :gte
    end
  end
end

describe Symbol do
  it "returns an 'equal' meta field with #eq" do
    :name.eq.should == Ricordami::MetaField.new(:name, :eq)
  end

  it "returns a 'less than' meta field with #lt" do
    :name.lt.should == Ricordami::MetaField.new(:name, :lt)
  end

  it "returns a 'less than or equal' meta field with #lte" do
    :name.lte.should == Ricordami::MetaField.new(:name, :lte)
  end

  it "returns a 'greater than' meta field with #gt" do
    :name.gt.should == Ricordami::MetaField.new(:name, :gt)
  end

  it "returns a 'greater than or equal' meta field with #gte" do
    :name.gte.should == Ricordami::MetaField.new(:name, :gte)
  end

  it "returns an 'include' meta field with #in" do
    :name.in.should == Ricordami::MetaField.new(:name, :in)
  end
end
